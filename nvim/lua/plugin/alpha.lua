return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      [[            █████                                                   ]],
      [[           ▒▒███                                                    ]],
      [[ █████ ████ ▒███████    ██████             █████ ███ █████  ████████]],
      [[▒▒███ ▒███  ▒███▒▒███  ███▒▒███ ██████████▒▒███ ▒███▒▒███  ███▒▒███ ]],
      [[ ▒███ ▒███  ▒███ ▒███ ▒███ ▒███▒▒▒▒▒▒▒▒▒▒  ▒███ ▒███ ▒███ ▒███ ▒███ ]],
      [[ ▒███ ▒███  ▒███ ▒███ ▒███ ▒███            ▒▒███████████  ▒███ ▒███ ]],
      [[ ▒▒████████ ████ █████▒▒██████              ▒▒████▒████   ▒▒███████ ]],
      [[  ▒▒▒▒▒▒▒▒ ▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒▒                ▒▒▒▒ ▒▒▒▒     ▒▒▒▒▒███ ]],
      [[                                                               ▒███ ]],
      [[                                                               █████]],
      [[                                                              ▒▒▒▒▒ ]],
    }

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    dashboard.section.footer.val = "uho-wq"

    dashboard.config.opts.noautocmd = true

    -- Tokyo Night カラー
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7" })
    dashboard.section.header.opts.hl = "AlphaHeader"

    alpha.setup(dashboard.config)
  end,
}
