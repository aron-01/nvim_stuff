local M = {}

local dapui_windows = require('dapui.windows')
local dapui = require('dapui')
local dap = require('dap')

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpointColor', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected',
  { text = '', texthl = 'DapBreakpointRejectedColor', linehl = '', numhl = '' })

vim.cmd [[highlight DapBreakpointColor guifg=#FF5F5F guibg=NULL]]
vim.cmd [[highlight DapBreakpointRejectedColor guifg=#fff guibg=NULL]]

vim.keymap.set('n', '<F6>', ':lua require("custom_dap").get_data()<CR>', { noremap = true, silent = true })

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    -- CHANGE THIS to your path!
    command = 'codelldb',
    args = { "--port", "${port}" },
    -- On windows you may have to uncomment this:
    detached = false,
  }
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return require("dap.utils").pick_file()
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { '/home/ron/.config/nvim/vscode-php-debug/out/phpDebug.js' }
}

dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = "9003",
    log = false,
    pathMappings = {
      ["/app/"] = "${workspaceFolder}/", -- drupal
      ["/app"] = "${workspaceFolder}/",  -- drupal
      -- ["/application/"] = "${workspaceFolder}/" -- docker
    },
    console = 'integratedTerminal'
  }
}

vim.api.nvim_create_augroup("CustomDap", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
  group = "CustomDap",
  callback = function()
    for _, layout in ipairs(dapui_windows.layouts) do
      if layout:is_open() then
        dapui.close()
        break
      end
    end
  end
})

require("mason-nvim-dap").setup({
  ensure_installed = { "python", "delve" },
  automatic_installation = true,
  handlers = {
    function(config)
      require("mason-nvim-dap").default_setup(config)
    end,
  },
})

-- dap.configurations.python = {
--   -- The first three options are required by nvim-dap
--   -- The first three options are required by nvim-dap
--   type = 'python',   -- the type here established the link to the adapter definition: `dap.adapters.python`
--   request = 'launch',
--   name = "Launch file",
--
--   -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
--   program = "${file}",   -- This configuration will launch the current file if used.
--   pythonPath = function()
--     -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
--     -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
--     -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
--     local cwd = vim.fn.getcwd()
--     if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
--       return cwd .. '/venv/bin/python'
--     elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
--       return cwd .. '/.venv/bin/python'
--     else
--       return '/usr/bin/python'
--     end
--   end,
-- }

dap.adapters.python = {
  type = "server",
  host = "127.0.0.1",
  port = 5678,
  options = {
    source_filetype = "python",
  },
}

dap.configurations.python = {
  {
    name = "Python: Remote Attach",
    type = "python",
    request = "attach",
    mode = "remote",
    pathMappings = {
      {
        localRoot = "${workspaceFolder}",
        remoteRoot = "."
      }
    },
    justMyCode = false
  },
}

return M
