vim.keymap.set("n", "gn", function()
  vim.diagnostic.jump({ count = 1 })
end, { buffer = vim.api.nvim_get_current_buf(), remap = false })
vim.keymap.set("n", "gb", function()
  vim.diagnostic.jump({ count = -1 })
end, { buffer = vim.api.nvim_get_current_buf(), remap = false })

vim.keymap.set("n", "gd", function() require("utils").CustomGoToDefinition() end)
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ focusable = true }) end)
vim.keymap.set('n', 'gD', function() vim.lsp.buf.definition() end)
vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.declaration() end)
vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end)
vim.keymap.set('n', 'go', function() vim.lsp.buf.type_definition() end)
vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end)
vim.keymap.set('n', 'gs', function() vim.lsp.buf.signature_help() end)
vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end)
vim.keymap.set('n', '<F4>', function() vim.lsp.buf.code_action() end)
vim.keymap.set('x', '<F3>', function() vim.lsp.buf.range_code_action() end)
vim.keymap.set('n', 'gl', function() vim.diagnostic.open_float() end)

vim.lsp.config("cssls", {
  on_attach = function(client, _)
    client.server_capabilities.documentSymbolProvider = nil
    client.server_capabilities.workspaceSymbolProvider = nil
    client.server_capabilities.referencesProvider = nil
  end,
})

-- if not configs.drupal then
--   configs.drupal = {
--     default_config = {
--       cmd = { '/home/aron/programs/drupal-lsp/drupal-lsp' },
--       filetypes = { 'php' },
--       root_dir = function(fname)
--         return require("lspconfig").util.root_pattern('.git')(fname)
--       end
--     },
--   }
-- end
vim.lsp.config("custom_scss", {
  cmd = { '/home/aron/programs/custom_scss_lsp/scss-lsp' },
  filetypes = { 'scss' },
  root_markers = { '.git' },
})

-- if not configs.drupal_rust_lsp then
--   configs.drupal_rust_lsp = {
--     default_config = {
--       cmd = { '/home/aron/programs/drupal-lsp-rust/target/debug/drupal-lsp-rust' },
--       -- cmd = { '/home/ron/programs/drupal-lsp-rust/target/release/drupal-lsp-rust' },
--       filetypes = { 'php', 'yaml', 'yml' },
--       autostart = true,
--       root_dir = function(fname)
--         return require("lspconfig").util.root_pattern('.git')(fname)
--       end
--     },
--   }
-- end


vim.lsp.config("volar", {
  init_options = {
    vue = {
      hybridMode = false,
    },
    typescript = {
      tsdk = '/usr/local/lib/node_modules/typescript/lib/'
    }
  },
})

vim.lsp.config("intelephense", {
  on_attach = function() vim.notify("loaded intelephense") end,
  autostart = true,
  root_markers = { ".git" }, -- not composer json !
  filetypes = {
    "php",
    "inc",
    "module",
    "yml",
    "install",
    "phtml",
    "theme",
  },
  settings = {
    ["intelephense"] = {
      environment = {
        includePaths = {
          "./web/core/includes",
          "./core/includes"
        }
      },
      format = {
        braces = "k&r",
      },
      files = {
        associations = {
          "*.inc",
          "*.theme",
          "*.install",
          "*.module",
          "*.profile",
          "*.php",
          "*.phtml"
        }
      },
    }
  }
})

vim.lsp.config("lua_ls", {
  root_markers = { ".git" },
});

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {
        ["web/core/assets/schemas/v1/metadata.schema.json"] = "/**/*/*.component.yml",
      },
    },
  }
})

vim.lsp.enable("custom_scss")
vim.lsp.enable("intelephense")
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("clangd")
vim.lsp.enable("cssls")
vim.lsp.enable("gopls")
vim.lsp.enable("html-lsp")
vim.lsp.enable("html")
vim.lsp.enable("intelephense")
vim.lsp.enable("yamlls")
vim.lsp.enable("vtsls")

function MasonLspPackages()
	local registry = require("mason-registry")
	local lsp = {}
	for _, pkg_info in ipairs(registry.get_installed_packages()) do
		for _, type in ipairs(pkg_info.spec.categories) do
			if type == "LSP" then
				table.insert(lsp, pkg_info.name)
			end
		end
	end
	return lsp
end


vim.diagnostic.config({
  virtual_text = true,
})
