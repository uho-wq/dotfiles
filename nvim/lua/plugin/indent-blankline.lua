return {
  'lukas-reineke/indent-blankline.nvim',
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("ibl").setup {
      -- インデントガイドの設定
      indent = {
        char = "│",
        tab_char = "│",
      },
      -- スコープのハイライト
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        injected_languages = true,
        include = {
          node_type = {
            go = {
              "func_literal",
              "function_declaration",
              "method_declaration",
              "if_statement",
              "block",
              "expression_switch_statement",
              "for_statement",
            },
          },
        },
      },
      -- 除外設定
      exclude = {
        filetypes = {
          "help",
          "terminal",
          "dashboard",
          "packer",
          "lspinfo",
          "TelescopePrompt",
          "TelescopeResults",
          "mason",
          "nvchad_cheatsheet",
          "lsp-installer",
          "norg",
          "",
        },
        buftypes = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      },
    }
  end,
}
