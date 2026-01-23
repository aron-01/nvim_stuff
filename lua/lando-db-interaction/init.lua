-- require("plenary.reload").reload_module("lando-db-interaction")
local driver = require "luasql.mysql"
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local job = require("plenary.job")

local inspect = function(x)
  vim.print(vim.inspect(x))
end

local M = {}

M.config = nil
M.stdout_collector = ""
M.host = nil
M.port = nil

M.creds = {
  password = nil,
  user = nil,
  database = nil
}

M.telescope_picker = function(items)
  local picker = pickers.new({}, {
    prompt_title = "Select a view mode",
    finder = require("telescope.finders").new_table {
      results = items,
    },
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()[1]
        M.query_view_mode(selection)
      end)
      return true
    end,
  })
  picker:find()
end

M.put_in_buffer = function(lines)
  if type(lines) == "table" then
    lines = vim.inspect(lines)
    lines = vim.split(lines, "\n")
  end

  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end

  vim.schedule(function()
    vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
    -- vim.api.nvim_win_set_cursor(M.window, { vim.api.nvim_buf_line_count(M.buffer), 0 })
  end)
end

M.get_view_mode_order = function(json)
  local content = json["content"]
  local sorted = {}
  for key, value in pairs(content) do
    value.old_key = key
    table.insert(sorted, value)
  end
  return sorted
end

M.preprocess_class_name = function(class_name)
  local new_class_name = string.gsub(class_name, "_", "-")
  new_class_name = "field--name-" .. new_class_name
  return new_class_name
end

---@param json table<string, table<any>>>
---@return string
M.generate_scss = function(json)
  local scss = ""
  local pattern = ".%s {\n\n}\n\n"
  for _, value in pairs(json) do
    if value.old_key == "" then
      goto continue
    end
    local class_name = M.preprocess_class_name(value.old_key)
    local new_element = string.format(pattern, class_name)
    scss = scss .. new_element
    ::continue::
  end
  return scss
end

M.decode_lando_info = function(json)
  for i, service in ipairs(json) do
    if service["service"] == "database" then
      M.host = service["external_connection"]["host"]
      M.port = service["external_connection"]["port"]
      M.creds.password = service["creds"]["password"]
      M.creds.user = service["creds"]["user"]
      M.creds.database = service["creds"]["database"]
    end
  end
end

M.php_deserialize = function(serialized_string)
  local path_to_script = debug.getinfo(1).source:match("@?(.*/)") .. "deserialize.php"
  local result = vim.system({ "/usr/bin/php", path_to_script }, {
    stdin = { serialized_string },
  }):wait()

  local success, res = pcall(function()
    local json = vim.json.decode(result["stdout"])
    return json
  end)
  if success then
    return res
  else
    return nil
  end
end

M.query_view_mode = function(view_mode)
  local env = driver.mysql()
  local conn = env:connect(M.creds.database, M.creds.user, M.creds.password, M.host, M.port)

  conn:execute("USE " .. M.creds.database)

  local cur = conn:execute("SELECT data FROM config WHERE name = '" .. view_mode .. "'")
  local row = cur:fetch({}, "a")

  while row do
    local data = row.data
    local json = M.php_deserialize(data)
    local sorted = M.get_view_mode_order(json)
    local scss = M.generate_scss(sorted)
    M.put_in_buffer(scss)
    row = cur:fetch(row, "a")
  end
  env:close()
end

M.query_view_mode_list = function()
  local env = driver.mysql()
  local conn = env:connect(M.creds.database, M.creds.user, M.creds.password, M.host, M.port)
  conn:execute("USE " .. M.creds.database)

  local cur = conn:execute([[SELECT name FROM config WHERE name LIKE "%core.entity_view_display%"]])
  local row = cur:fetch({}, "a")
  local names = {}

  while row do
    local data = row.name
    table.insert(names, data)
    row = cur:fetch(row, "a")
  end

  env:close()
  return names
end

M.do_process = function()
  local config_names = M.query_view_mode_list()
  M.telescope_picker(config_names)
end

M.start = function()
  if M.creds.password == nil then
    local info_job = job:new({
      command = "lando",
      args = { "info", "--format", "json" },
      on_stdout = function(_, line)
        vim.schedule(function()
          M.stdout_collector = M.stdout_collector .. line
        end)
      end,

      on_stderr = function(_, line)
        vim.schedule(function()
          vim.notify("Error: " .. line, vim.log.levels.ERROR, { title = "Lando DB Interaction" })
        end)
      end,

      on_exit = function(_, code)
        vim.schedule(function()
          local json = vim.json.decode(M.stdout_collector)
          M.decode_lando_info(json)
          M.do_process()
        end)
      end
    })
    info_job:start()
  else
    M.do_process()
  end
end

M.setup = function()
  vim.api.nvim_create_user_command("ViewModeIntoSass", function()
    M.start()
  end, {})
end

return M

