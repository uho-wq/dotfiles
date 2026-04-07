return {
  "supermaven-inc/supermaven-nvim",
  event = "VeryLazy",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-\\>",
        clear_suggestion = "<C-]>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      log_level = "info",
      disable_inline_completion = false,
      disable_keymaps = false,
    })
  end,
}
