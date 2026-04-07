return {
  "YuminosukeSato/gogentest",
  ft = "go",
  dependencies = { "neovim/nvim-lspconfig" },
  keys = {
    { "<leader>tG", function() require("gogentest").generate() end, desc = "Generate Go Test" },
  },
}
