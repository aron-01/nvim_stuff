local function get_project_string()
  local cwd = vim.fn.getcwd()
  local git = require("lspconfig").util.root_pattern('.git')(cwd)
  if git then
    local split = vim.split(git, "/")
    local shortened = split[#split]
    vim.loop.fs_stat(git)
    return shortened
  else
    local processed = string.gsub(cwd, "/", "_")
    return processed
  end
end

local global_note = require("global-note")
global_note.setup({
  directory = "~/notes/",
  additional_presets = {
    project_local = {
      command_name = "ProjectNote",
      filename = function()
        return get_project_string() .. ".md"
      end,

      title = function()
        return "Project Note: " .. get_project_string()
      end,
    },
  }
})

vim.keymap.set("n", "<leader>n", function()
  global_note.toggle_note("project_local")
end, {
  desc = "Toggle project note",
})
