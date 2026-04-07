return {
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "f3fora/cmp-spell",
      "uga-rosa/cmp-dictionary",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
          preselect = cmp.PreselectMode.None,
          snippet = {
              expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
              end,
          },
          sources = {
              { name = "nvim_lsp" },
              -- { name = "buffer" },
              { name = "path" },
          },
          mapping = cmp.mapping.preset.insert({
              ['<C-n>'] = cmp.mapping.select_next_item(),
              ['<C-p>'] = cmp.mapping.select_prev_item(),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<TAB>'] = cmp.mapping.confirm { select = true },
          }),
          experimental = {
              ghost_text = true,
          },
      })
      cmp.setup.cmdline('/', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
              { name = 'buffer' }
          }
      })
    end,
  },
}
