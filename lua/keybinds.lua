local function query_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  vim.cmd([[Telescope lsp_workspace_symbols query=]] .. word)
end

vim.keymap.set("n", "<", "<<", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz <CR>", { silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz <CR>", { silent = true })
vim.keymap.set("n", "<leader>ft", ":Telescope aerial <CR>", { silent = true })
vim.keymap.set("n", "<F5>", vim.cmd.UndotreeToggle)

vim.keymap.set("n", "<S-Tab>", ":b#<CR>", { silent = true })
vim.keymap.set("n", "<leader>cc", ":Telescope neoclip default<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", ":NvimTreeFocus<CR>", { silent = true })
vim.keymap.set("n", "<leader>fa", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>fq", ":SortDeclarations<CR>", { silent = true }) -- custom command
vim.keymap.set("n", "<leader>qf", ":Trouble qflist<CR>", { silent = true })   -- custom command
-- vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>")
vim.keymap.set("n", "<leader>le", vim.diagnostic.goto_next, { buffer = vim.api.nvim_get_current_buf() })
vim.keymap.set("n", "<leader>lw", vim.diagnostic.goto_prev, { buffer = vim.api.nvim_get_current_buf() })
vim.keymap.set("n", "<leader>pV", ":Telescope projects<CR>", { silent = true })
vim.keymap.set("n", "<leader>pv", ":ProjectView <CR>", { silent = true })      -- custom command
vim.keymap.set("n", "<leader>fp", ":Telescope resume <CR>", { silent = true }) -- custom command
vim.keymap.set("n", "<leader>r", ":NvimTreeFindFile<CR>", { silent = true })
vim.keymap.set("n", "<leader>fT", ":Telescope lsp_workspace_symbols <CR>", { silent = true })


-- vim.keymap.set('n', '<Leader>df', function()
--   local widgets = require('dap.ui.widgets')
--   widgets.centered_float(widgets.frames)
-- end)

vim.keymap.set("n", "<leader>k", require('dap.ui.widgets').hover, { silent = true })
vim.keymap.set("n", "<leader>dp", require('dap.ui.widgets').preview, { silent = true })

vim.keymap.set('n', 'ű', function() require('dap').continue() end)
vim.keymap.set('n', 'ő', function() require('dap').terminate() end)
vim.keymap.set('n', 'á', function() require('dap').step_over() end)
vim.keymap.set('n', 'ü', function() require('dap').step_into() end)
vim.keymap.set('n', 'ó', function() require('dap').step_out() end)
vim.keymap.set('n', 'ú', function() require('dap').run_last() end)

vim.keymap.set("n", "<leader>sf", query_word_under_cursor, { silent = true })

vim.keymap.set("n", "<leader>r", ":NvimTreeFindFile<CR>", { silent = true })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>s", [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])


vim.keymap.set("n", "<leader>tp", [[:Trouble telescope <CR>]], { silent = true })
vim.keymap.set("n", "<leader>tq", [[:Trouble quickfix <CR>]], { silent = true })
vim.keymap.set("n", "<leader>tt", [[:Trouble diagnostics <CR>]], { silent = true })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
-- vim.keymap.set("n", "<leader>dr", ":lua require('builder').setup()<CR>", { silent = true })
vim.keymap.set("n", ">", ">>", { silent = true })
vim.keymap.set("n", "x", [[v"_d]]) -- remove single character and put it in void register
vim.keymap.set("n", "zz", "zz zH") -- center cursor
vim.keymap.set("n", "ZZ", ":qa!<CR>")


vim.keymap.set("n", "mg", "`") -- reasonable marks

vim.keymap.set("v", ">", ">gv", { silent = true })
vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", "<c-j>", ":m '>+1<CR>gv=gv") -- move selection one line up
vim.keymap.set("v", "<c-k>", ":m '<-2<CR>gv=gv") -- down
vim.keymap.set("v", "J", "j")                    -- can hold shift while in v mode
vim.keymap.set("v", "K", "k")                    -- can hold shift while in v mode

vim.keymap.set("n", "<F8>", ":lua require('dapui').toggle()<CR>")
vim.keymap.set("n", "<F9>", ":DapToggleBreakpoint<CR>")

vim.keymap.set("x", "<leader>p", [[P]])
vim.keymap.set("n", "<F9>", ":DapToggleBreakpoint<CR>")

local ls = require("luasnip")

vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-H>", function() ls.jump(-1) end, { silent = true })

vim.keymap.set("i", "<C-j>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })

-- vim.api.nvim_set_keymap('i', '<C-8>', [[<C-O>:lua require('copilot').complete_comment()<CR>]], { noremap = true, silent = true })
-- :copilot#Accept('
-- ')
--
vim.cmd([[imap <silent><script><expr> <C-f> copilot#Accept("\<CR>")]])
vim.keymap.set("i", "<C-j>", "copilot#Next()", { expr = true, silent = true })
vim.keymap.set("i", "<C-k>", "copilot#Previous()", { expr = true, silent = true })
vim.keymap.set("i", "<C-x>", "copilot#Dismiss()", { expr = true, silent = true })
vim.keymap.set("i", "<C-s>", "copilot#Suggest()", { expr = true, silent = true })
vim.keymap.set("i", "<F10>", "copilot#Comment()", { expr = true, silent = true })

-- file
--
