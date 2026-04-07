return {
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Mason setup
      require('mason').setup()

      -- Define on_attach function
      local on_attach = function(client, bufnr)
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set('n', 'gD', function()
              vim.cmd('vsplit')
              vim.lsp.buf.definition()
          end, opts)
          vim.keymap.set('n', '<space>f', function()
              vim.lsp.buf.format { async = true }
          end, opts)
      end

      -- Global on_attach for all LSP clients
      vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              -- Skip Copilot and only apply to actual language servers
              if client.name ~= "GitHub Copilot" and client.name ~= "copilot" then
                  on_attach(client, ev.buf)
              end
          end,
      })

      require("mason-lspconfig").setup({
          ensure_installed = { "gopls", "bashls", "ruff", "templ" },
          automatic_installation = true,
          handlers = {
              function(server)
                  local opt = {
                      capabilities = require('cmp_nvim_lsp').default_capabilities(),
                      on_attach = function(client, bufnr)
                          -- Disable semantic tokens to avoid buffer reference issues
                          client.server_capabilities.semanticTokensProvider = nil
                      end
                  }

                  -- Add gopls specific settings
                  if server == "gopls" then
                      opt.settings = {
                          gopls = {
                              analyses = {
                                  unusedparams = true,
                              },
                              staticcheck = true,
                              gofumpt = true,
                          }
                      }
                      opt.filetypes = { "go", "gomod", "gowork", "gotmpl", "templ" }
                  end

                  if server == "ruff" then
                      opt = {
                        init_options = {
                          settings = {
                            lineLength = 88,
                          },
                          lint = {
                            select = {
                              "E", "W", "F", "I", "B", "C4", "UP",
                            },
                            ignore = {
                              "E501"
                            },
                          }
                        }
                      }
                  end

                  if server == "templ" then
                      opt.cmd = { "templ", "lsp" }
                      opt.filetypes = { "templ" }
                      opt.root_dir = require('lspconfig.util').root_pattern("go.work", "go.mod", ".git")
                  end

                  require('lspconfig')[server].setup(opt)
              end
          }
      })

      -- Diagnostics configuration
      vim.diagnostic.config({
        update_in_insert = false,
        virtual_text = {
          format = function(diagnostic)
            return string.format('%s (%s: %s)', diagnostic.message, diagnostic.source, diagnostic.code)
          end,
        },
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = false,
  },
}
