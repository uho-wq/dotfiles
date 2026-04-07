return {
  'mvllow/modes.nvim',
  tag = 'v0.2.1',

  event = 'VeryLazy',
  config = function()
    require('modes').setup({
      colors = {
        copy = "#4C9855",
        delete = "#c75c6a",
        format = "#c79585",
        insert = "#151B23",
        replace = "#245361",
        visual = "#9745be",
      },
      line_opacity = 0.6,
      set_cursor = false,
      set_cursorline = true,
      set_number = true,
      set_signcolumn = true,
      ignore = { 'NvimTree', 'TelescopePrompt', 'neo-tree' }
    })
  end,
}
