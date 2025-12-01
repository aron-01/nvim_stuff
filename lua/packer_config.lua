local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  {
    -- https://github.com/rmagatti/auto-session
    'rmagatti/auto-session',
    init = function()
      require("auto-session").setup {
        auto_session_enabled = true,
        log_level = "error",
        cwd_change_handling = {
          post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
            require("lualine").refresh()     -- refresh lualine so the new session name is displayed in the status bar
          end,
        },
      }
    end
  },
  {
    "mhartington/formatter.nvim",
    event = "VeryLazy",
    lazy = true,
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    setup = function()
      local null_ls = require("null-ls")
      return {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.completion.spell,
        null_ls.builtins.diagnostics.cpplint,
      }
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!:).
    hependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    lazy = false,
    priority = 2,
    init = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./drupal-smart-snippets" } })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },
  {
    "nvim-lua/plenary.nvim",
    lazy = true
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "BufEnter",
    dependencies = { { "nvim-lua/plenary.nvim" } }
  },
  "ethanholz/nvim-lastplace", -- good stuff
  {
    "rebelot/kanagawa.nvim",
    config = function()
    end,
    init = function()
      vim.cmd("colorscheme kanagawa")
    end,
    lazy = false,
    priority = 2000,
  },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      --
      snippets = {
        preset = "luasnip",
      },
      keymap = {
        preset = 'default',
        -- ['<C-f>'] = { function(cmp) cmp.show({ providers = { 'snippets', 'lsp' } }) end },
        ['<C-,>'] = { "cancel" },
        ['<C-z>'] = { function(cmp) cmp.accept() end },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },
      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = true },
        list = {
          selection = {
            auto_insert = true
          }
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local lspkind = require("lspkind")
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  else
                    icon = require("lspkind").symbolic(ctx.kind, {
                      mode = "symbol",
                    })
                  end

                  return icon .. ctx.icon_gap
                end,

                -- Optionally, use the highlight groups from nvim-web-devicons
                -- You can also add the same function for `kind.highlight` if you want to
                -- keep the highlight groups in sync with the icons.
                highlight = function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              }
            }
          }
        }
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "rust" }

    },
    opts_extend = { "sources.default" },
    priority = 3,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   config = function()
  --     local cmp = require 'cmp'
  --     local compare = require('cmp.config.compare')
  --     local mapping = require('cmp.config.mapping')
  --     local types = require('cmp.types')
  --     cmp.setup {
  --       snippet = {
  --         expand = function(args)
  --           require('luasnip').lsp_expand(args.body)
  --         end,
  --       },
  --       mapping = {
  --         ['<C-n>'] = mapping(mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }), { 'i', 'c' }),
  --         ['<C-p>'] = mapping(mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }), { 'i', 'c' }),
  --         ['<C-y>'] = mapping.confirm({ select = false }),
  --         ['<C-z>'] = mapping.confirm({ select = false }),
  --         --   ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
  --         --   ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  --         --   ['<C-d>'] = cmp.mapping.scroll_docs(-4),
  --         --   ['<C-u>'] = cmp.mapping.scroll_docs(4),
  --         --   ['<C-z>'] = cmp.mapping.complete(),
  --         -- --   ['<C-e>'] = cmp.mapping.close(),
  --         --   -- ['<C-z>'] = cmp.mapping.confirm({ select = true }),
  --         -- --   ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
  --         -- --   ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
  --       },
  --       sources = {
  --         { name = 'nvim_lsp' },
  --         { name = 'luasnip' },
  --         { name = 'buffer' },
  --         { name = 'path' },
  --         { name = 'nvim_lua' },
  --         {
  --           name = "lazydev",
  --           group_index = 0,
  --         }
  --       }
  --     }
  --   end,
  --   dependencies = {
  --     "hrsh7th/cmp-buffer",       -- Completion source
  --     "hrsh7th/cmp-nvim-lsp",     -- Completion source
  --     "hrsh7th/cmp-path",         -- Completion source
  --     "hrsh7th/cmp-nvim-lua",     -- Completion source
  --     "saadparwaiz1/cmp_luasnip", -- Completion source
  --   },
  --   priority = 800,
  --   lazy = false
  -- }, -- Autocomplete engine
  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    'Wansmer/treesj',
    -- keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({ use_default_keymaps = true })
    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "love2d/library" },
      },
    },
  },

  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  { "LuaCATS/love2d",       lazy = true }, -- love2d typings

  "kdheepak/lazygit.nvim",                 -- <leader>gg
  "mbbill/undotree",                       --<F5>
  {
    "ray-x/lsp_signature.nvim",            -- automatic hover on function
    event = "VeryLazy",
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  "norcalli/nvim-colorizer.lua",
  "nvim-treesitter/nvim-treesitter-context",
  "nvim-treesitter/playground",
  {
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").init()
    end
  },
  "nvim-lua/popup.nvim",
  -- "saadparwaiz1/cmp_luasnip", -- Completion source
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate", priority = 1200 },
  {
    "lewis6991/gitsigns.nvim", -- TODO make keybinds for this
  },
  "chentoast/marks.nvim",      -- TODO learn how to use this effectively
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons", opt = false },
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    -- or                            , branch = '0.1.x',
    dependencies = { { "nvim-lua/plenary.nvim" } },
  },
  "nvim-telescope/telescope-live-grep-args.nvim",
  "github/copilot.vim",
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      -- { "hrsh7th/nvim-cmp" },
      -- { "hrsh7th/cmp-buffer" },
      -- { "hrsh7th/cmp-path" },
      -- { "saadparwaiz1/cmp_luasnip" },
      -- { "hrsh7th/cmp-nvim-lsp" },
      -- { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      -- Snippet Collection (Optional)
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    tag = "nightly",                 -- optional, updated every week. (see issue #1193)
  },
  {                                  -- :AerialOpen
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    config = function()
      require("aerial").setup(
        {
          backends = { "treesitter", "lsp", "man" },
        })
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    config = function()
      require("nvim-dap-virtual-text").setup(
        {
          only_first_definition = false,
          all_references = true,
        })
    end,
  },
  {
    "rmagatti/goto-preview", -- preview definition,
    event = "VeryLazy",      -- TODO  make gd always open with goto-preview if the function is a non git file
    config = function()
      require("goto-preview").setup({
        width = 100,
        height = 70,
        default_mappings = true,
        post_open_hook = function(buffer, _)
          -- Vert split/Move to right
          vim.cmd("wincmd L")
          vim.api.nvim_buf_set_keymap(buffer, "n", "gd", ":lua vim.lsp.buf.definition()<CR>",
            { noremap = true, silent = true })
        end,
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
  },
  {
    'leoluz/nvim-dap-go',
    init = function()
      require('dap-go').setup(
        {
          dap_configurations = {
            {
              -- Must be "go" or it will be ignored by the plugin
              type = "go",
              name = "Attach remote",
              mode = "remote",
              request = "attach",
            },
          },
          -- delve configurations
          delve = {
            -- the path to the executable dlv which will be used for debugging.
            -- by default, this is the "dlv" executable on your PATH.
            path = "dlv",
            -- time to wait for delve to initialize the debug session.
            -- default to 20 seconds
            initialize_timeout_sec = 20,
            -- a string that defines the port to start delve debugger.
            -- default to string "${port}" which instructs nvim-dap
            -- to start the process in a random available port.
            -- if you set a port in your debug configuration, its value will be
            -- assigned dynamically.
            port = "${port}",
            -- additional args to pass to dlv
            args = {},
            -- the build flags that are passed to delve.
            -- defaults to empty string, but can be used to provide flags
            -- such as "-tags=unit" to make sure the test suite is
            -- compiled during debugging, for example.
            -- passing build flags using args is ineffective, as those are
            -- ignored by delve in dap mode.
            -- avaliable ui interactive function to prompt for arguments get_arguments
            build_flags = {},
            -- whether the dlv process to be created detached or not. there is
            -- an issue on Windows where this needs to be set to false
            -- otherwise the dlv server creation will fail.
            -- avaliable ui interactive function to prompt for build flags: get_build_flags
            detached = vim.fn.has("win32") == 0,
            -- the current working directory to run dlv from, if other than
            -- the current working directory.
            cwd = nil,
          },
          -- options related to running closest test
          tests = {
            -- enables verbosity when running the test.
            verbose = false,
          },
        }
      )
    end,
    dependencies = { 'mfussenegger/nvim-dap' }
  },
  { "nvim-telescope/telescope-dap.nvim" },
  { "jay-babu/mason-nvim-dap.nvim" },
  { -- clipboard manager
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { "kkharji/sqlite.lua" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("neoclip").setup()
    end,
  },
  -- use({
  --   "okuuva/auto-save.nvim",
  --   config = function()
  --     require("auto-save").setup
  --     {
  --       trigger_events = {},
  --     }
  --   end,
  -- })
  {
    "danymat/neogen",
    -- event = "VeryLazy",
    config = function()
      require("neogen").setup({ snippet_engine = "luasnip" })
    end,
    dependencies = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    -- tag = "*"
  },
  {
    "folke/trouble.nvim", -- <leader>tt TODO learn how to use this
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup(
      -- {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- }
      )
    end,
  },
  { "backdround/global-note.nvim" },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  }
})

require("neoclip").setup({ enable_persistent_history = false, default_register = "+" })
require("gitsigns").setup()
require("lualine").setup({})
require("treesitter-context").setup()
require('dapui').setup()
require 'lsp_signature'.setup()

require("colorizer").setup()
require("nvim-lastplace").setup({})

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = { "markdown" },
  },
  indent = {
    enable = true,
  },
})

require 'marks'.setup {
  mappings = {
    set_next = "m,",
    next = "m]",
    preview = "m:",
    set_bookmark0 = "m0",
    prev = false -- pass false to disable only this default mapping
  }
}

require("formatter").setup {
  -- Use the special "*" filetype for defining formatter configurations on
  -- any filetype
  ["*"] = {
    -- "formatter.filetypes.any" defines default configurations for any
    -- filetype
    require("formatter.filetypes.any").remove_trailing_whitespace
  }
}
require("neogit").setup {}
