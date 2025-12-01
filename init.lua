require("options")
require("packer_config")
require("tele")
require("tree")
require("treesitter_conf")
require("harpoon_conf")
require("custom_commands")
require("lsp_conf")
require("keybinds")
require("custom_dap")
require("custom_snippets")
require("global_note_conf")
-- require("diff-split-window").setup()
require("lando-db-interaction").setup()
require("preload-google-fonts").setup()
require("show-diff-of-changed-text").setup()

local util = require "formatter.util"
require("formatter").setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    php =
        function()
          return {
            exe = "/home/ron/.config/composer/vendor/squizlabs/php_codesniffer/bin/phpcbf",
            args = {
              "--standard=Drupal",
              "--extensions=php,module,inc,install,test,profile,theme,css,info,txt,md,yml",
              util.get_current_buffer_file_path(),
            },
            stdin = false,
          }
        end,
    css = require("formatter.filetypes.css").cssbeautify,
    scss = require("formatter.defaults.prettierd"),
    rust = require("formatter.filetypes.rust").rustfmt
  }
}

-- what does this do
vim.cmd([[
  augroup FormatAutogroup
    autocmd!
    autocmd User FormatterPost checktime
  augroup END
]])
