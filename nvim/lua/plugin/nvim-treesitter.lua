return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require('nvim-treesitter.configs').setup {
      -- 必要な言語パーサーをインストール
      ensure_installed = {
        "lua", "vim", "vimdoc", "javascript", "typescript", "python", "c", "cpp",
        "bash", "markdown", "markdown_inline", "json", "yaml", "html", "css", "go", "gomod", "gosum", "templ"
      },
      
      -- 構文ハイライトを有効化
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      
      -- インデント機能を有効化
      indent = {
        enable = true,
      },
      
      -- 括弧のペアリングを強化
      matchup = {
        enable = true,
      },
      
      
      -- テキストオブジェクトの選択
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    }
  end,
}