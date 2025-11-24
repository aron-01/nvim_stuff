-- require("plenary.reload").reload_module("preload-google-fonts")

local M = {}
-- valid font format strings
-- http://www.iana.org/assignments/media-types/media-types.xhtml#font
-- collection 	font/collection 	[RFC8081]
-- otf 	font/otf 	[RFC8081]
-- sfnt 	font/sfnt 	[RFC8081]
-- ttf 	font/ttf 	[RFC8081]
-- woff 	font/woff 	[RFC8081]
-- woff2 	font/woff2 	[RFC8081]
--

--- @class Match
local Match = {}

Match.url = ""
Match.font_weight = ""
Match.font_family = ""
Match.character_set = ""
Match.font_format = ""

--- @param a Match
--- @param b Match
--- @return boolean
local function sortMatches(a, b)
  if a.font_family == b.font_family then
    return a.font_weight < b.font_weight
  end
  return a.font_family > b.font_family
end

function Match.new()
  local self = setmetatable({}, { __index = Match })
  return self
end

function Match:add_font_weight(font_weight)
  if self.font_weight == "" then
    self.font_weight = font_weight
  else
    self.font_weight = self.font_weight .. " | " .. font_weight
  end
end

function Match:set_url(url)
  self.url = url
end

function Match:set_font_family(font_family)
  self.font_family = font_family
end

function Match:add_character_set(character_set)
  if self.character_set == "" then
    self.character_set = character_set
  else
    self.character_set = self.character_set .. " | " .. character_set
  end
end

function Match:set_font_format(font_format)
  self.font_format = font_format
end

function Match:debug()
  print(
    self.url .. "\n" ..
    self.font_weight .. "\n" ..
    self.font_family .. "\n" ..
    self.character_set .. "\n" ..
    self.font_format .. "\n"
  )
end

--- @return string
function Match:to_html()
  local formatted = string.gsub(M.html_pattern, "!url", self.url)
  if self.font_format == "truetype" then
    self.font_format = "ttf"
  end

  formatted = string.gsub(formatted, "!format", self.font_format)
  local comment = string.format(" %s - %s - %s", self.font_family, self.font_weight, self.character_set)
  formatted = string.gsub(formatted, "!comment", comment)
  return formatted
end

M.html_pattern = [[
  {# !comment #}
  <link rel="preload" href="!url" as="font" type="font/!format" crossorigin>
]]

local print = function(x)
  if type(x) == "table" then
    vim.print((vim.inspect(x)))
  else
    vim.print(x)
  end
end

local curl = require('plenary.curl')

--- @param data Match[]
--- @return Match[]
M.group_by_url = function(data)
  --- @type table<string, Match>
  local grouped = {}

  for _, match in ipairs(data) do
    local key = match.url .. match.font_format .. match.font_family
    if grouped[key] == nil then
      local new_match = Match.new()
      new_match:set_url(match.url)
      new_match:set_font_family(match.font_family)
      new_match:set_font_format(match.font_format)
      grouped[key] = new_match
    end

    local character_set_appending = string.gsub(match.character_set, [[/%*]], "")
    character_set_appending = string.gsub(character_set_appending, "%*/", "")
    character_set_appending = vim.trim(character_set_appending)

    grouped[key]:add_character_set(character_set_appending)
    local font_weight_appending = vim.trim(match.font_weight)
    grouped[key]:add_font_weight(font_weight_appending)
  end
  --- @type Match[]
  local sorted_table = {}
  for _, value in pairs(grouped) do
    sorted_table[#sorted_table + 1] = value
  end
  table.sort(sorted_table, sortMatches)
  return sorted_table
end

M.clean_string = function(str)
  str = string.gsub(str, [["]], "")
  str = string.gsub(str, [[']], "")
  return str
end

M.setup = function()
  vim.api.nvim_create_user_command("PreloadGoogleFonts", function(opts)
    local url = opts.args
    M.procedure(url)
  end, {
    nargs = 1,
    bang = true,
    desc = "PreloadGoogleFonts",
  })
end

M.make_request = function(gfonts_url)
  local response = curl.get(gfonts_url, {
    -- google fonts sends wrong ttf instead of woff2 if you are not a browser
    raw = { "-A", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3" },
  }
  )
  return response.body
end

--- @return Match[]
M.parse = function(bufnr)
  local query = M.query()
  local parser = vim.treesitter.get_parser(bufnr, "scss", {})
  local tree = parser:parse()[1]
  local root = tree:root()
  --- @type Match[]
  local all_matches = {}

  for pattern, match, metadata in query:iter_matches(root, bufnr, 0, -1) do
    local current_match = {}
    local new_match = Match.new()

    for id, node in ipairs(match) do
      if node == nil then
        goto continue
      end
      local capture_name = query.captures[id]
      --- @type TSNode
      node = node[1]
      capture_name = M.clean_string(capture_name)
      local text_value = vim.treesitter.get_node_text(node, bufnr)
      text_value = M.clean_string(text_value)
      current_match[capture_name] = text_value
      ::continue::
    end
    -- techinically the query should guarantee these i think
    assert(current_match.url, "No url found")
    assert(current_match.format, "No format found")

    new_match:set_url(current_match["url"])
    new_match:set_font_family(current_match["font_family"])
    new_match:set_font_format(current_match["format"])
    new_match:add_font_weight(current_match["font-weight"])
    new_match:add_character_set(current_match["character_set_in_comment"])
    if (string.find(new_match.character_set, "latin")) then
      all_matches[#all_matches + 1] = new_match
    end
  end

  return all_matches
end


M.procedure = function(url)
  local response = M.make_request(url)

  if response == nil then
    vim.notify("No response from server")
    return
  end

  local temp_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(temp_buf, -1, -1, false, vim.split(response, "\n"))
  vim.bo[temp_buf].filetype = "scss"
  vim.api.nvim_open_win(temp_buf, true, {
    split = "right",
  })

  local parsed_info = M.parse(temp_buf)
  local grouped = M.group_by_url(parsed_info)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {  })
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "/*" })

  for _, match in ipairs(grouped) do
    vim.api.nvim_buf_set_lines(0, -1, -1, false, vim.split(match:to_html(), "\n"))
  end

  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "*/" })
  vim.api.nvim_buf_set_lines(0, -1, -1, false, vim.split(response, "\n"))
end


M.query = function()
  return vim.treesitter.query.parse(
    "scss",
    [[
(
  (comment) @character_set_in_comment
  .
  (
    at_rule
    (#eq? at_keyword "font-face")
    (block
      (declaration
        (
         (property_name) @font-family-property
         [
           (string_value)
           (plain_value)
          ] @font_family
        )(#eq? @font-family-property "font-family")
      )
      (declaration
        (
         (property_name) @font-weight-property
         (integer_value) @font-weight
        )(#eq? @font-weight-property "font-weight")
      )
      (declaration
        (#eq? property_name "src")
        (call_expression
          (#eq? function_name "url")
          (arguments
            (plain_value) @url
          )
        )
        (call_expression
          (#eq? function_name "format")
          (arguments
            (string_value) @format
          )
        )
      )
    )
  )
)
    ]]
  )
end

return M
