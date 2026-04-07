return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    providers = { "lsp", "treesitter", "regex" },
    delay = 100,
    large_file_cutoff = 2000,
    filetypes_denylist = {
      "dirbuf", "dirvish", "fugitive", "neo-tree",
      "NvimTree", "TelescopePrompt", "oil", "alpha",
      "lazy", "mason",
    },
    under_cursor = true,
    min_count_to_highlight = 1,
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
    -- Tokyo Night テーマに合わせた背景色ハイライト
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#6689D1" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#6689D1" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#6689D1", bold = true })
  end,
  keys = {
    { "]]", function() require("illuminate").goto_next_reference(false) end, desc = "Next Reference" },
    { "[[", function() require("illuminate").goto_prev_reference(false) end, desc = "Prev Reference" },
  },
}
