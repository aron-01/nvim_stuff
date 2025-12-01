local builtin = require('telescope.builtin')
local action_state = require("telescope.actions.state")
local helpers = require("telescope-live-grep-args.helpers")
local actions = require("telescope.actions")

---@param flag string spaces are included automatically
local function append_to_prompt(flag, post_cmd, restore_cursor)
  return function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local prompt = picker:_get_prompt()
    local winnr = vim.api.nvim_get_current_win()
    local pos = vim.fn.getcurpos(winnr)[3] - 3
    prompt = prompt .. " " .. flag
    picker:set_prompt(prompt)
    local new_pos = vim.fn.getcurpos(winnr)[3] - 3

    if post_cmd ~= nil then
      vim.cmd(post_cmd)
    end

    if restore_cursor == true then
      vim.cmd("normal! " .. new_pos - pos .. "h")
    end
  end
end

local function find_directory_and_focus()
  local function open_nvim_tree(prompt_bufnr, _)
    actions.select_default:replace(function()
      local api = require("nvim-tree.api")
      actions.close(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      api.tree.open()
      api.tree.find_file(selection.cwd .. "/" .. selection.value)
      api.node.open.edit()
    end)
    return true
  end

  require("telescope.builtin").find_files({
    find_command = { "fd", "--type", "directory", "--hidden", "--exclude", ".git/*" },
    attach_mappings = open_nvim_tree,
  })
end

local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

---@param ignore boolean
local function find_with_prefix(ignore)
  local config = {}
  if ignore then
    config.default_text = "--no-ignore "
  end
  pcall(function()
    local node_path = require("utils").get_nvim_tree_node_path()
    if not node_path then
      error("No node path found")
    end
    config.search_dirs = { node_path }
  end
  )
  require('telescope').extensions.live_grep_args.live_grep_args(config)
end



vim.keymap.set("n", "fd", find_directory_and_focus)
vim.keymap.set('n', '<leader>fv', live_grep_args_shortcuts.grep_word_under_cursor, {})
vim.keymap.set('v', '<leader>fv', live_grep_args_shortcuts.grep_visual_selection, {})
vim.keymap.set('n', '<leader>fl', function() find_with_prefix(false) end, {})
vim.keymap.set('n', '<leader>fL', function() find_with_prefix(true) end, {})
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>fF', ":Telescope find_files no_ignore=true<CR>", {})
vim.keymap.set('n', '<leader>cs', ":lua require('telescope.builtin').colorscheme({enable_preview = true})<CR>", {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fe', find_directory_and_focus, {})
vim.keymap.set('n', '<leader>fs', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

require("telescope").setup({
  extensions = {
    live_grep_args = {
      auto_quoting = false, -- enable/disable auto-quoting
    }
  },
  pickers = {
    colorscheme = {
      enable_preview = true,
    },
  },
  defaults = {
    mappings = {
      i = {
        ["<c-q>"] = require("telescope.actions").send_to_qflist,
        ["<c-t>"] = append_to_prompt("-t "),
        ["<c-i>"] = append_to_prompt("--no-ignore", nil, true),
        ["<c-g>"] = append_to_prompt("--iglob '!'", "normal! hh")
      },
      n = { ["<c-q>"] = require("telescope.actions").send_to_qflist },
    },
    file_ignore_patterns = { "node_modules", ".sql" }
  },
})

require("telescope").load_extension("live_grep_args")
require("telescope").load_extension("dap")
require("telescope").load_extension("neoclip")
-- require("telescope").load_extension("macroscope")
require("telescope").load_extension("aerial")
