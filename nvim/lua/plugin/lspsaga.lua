return {
  'nvimdev/lspsaga.nvim',
  event = "LspAttach",
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('lspsaga').setup({
      ui = {
        winbar_prefix = '',
        border = 'rounded',
        devicon = true,
        foldericon = true,
        title = true,
        expand = '⊞',
        collapse = '⊟',
        code_action = '',
        lines = { '┗', '┣', '┃', '━', '┏' },
        kind = nil,
        button = { '', '' },
        imp_sign = '󰳛 ',
        use_nerd = true,
      },
      hover = {
        max_width = 0.95,
        max_height = 0.9,
        open_link = 'gx',
        -- NOTE: open_cmd は環境に合わせて。macなら 'open', linuxなら 'xdg-open' など
        open_cmd = 'xdg-open',
      },
      diagnostic = {
        show_layout = 'float',
        show_normal_height = 10,
        jump_num_shortcut = true,
        auto_preview = false,
        max_width = 0.8,
        max_height = 0.6,
        max_show_width = 0.9,
        max_show_height = 0.6,
        wrap_long_lines = true,
        extend_relatedInformation = false,
        diagnostic_only_current = false,
        keys = {
          exec_action = 'o',
          quit = 'q',
          toggle_or_jump = '<CR>',
          quit_in_show = { 'q', '<ESC>' },
        },
      },
      code_action = {
        num_shortcut = true,
        show_server_name = false,
        extend_gitsigns = false,
        only_in_cursor = true,
        max_height = 0.3,
        cursorline = true,
        keys = {
          quit = 'q',
          exec = '<CR>',
        },
      },
      lightbulb = {
        enable = false,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
      },
      preview = { lines_above = 0, lines_below = 10 },
      scroll_preview = { scroll_down = '<C-f>', scroll_up = '<C-b>' },
      definition = {
        width = 0.9,
        height = 0.9,
        keys = { edit = '<CR>', vsplit = '<C-i>' },
      },
      finder = {
        max_height = 0.9,
        keys = { edit = '<CR>', vsplit = '<C-i>' },
      },
      request_timeout = 2000,
    })
  end,
  keys = {
    { 'gd', function()
        vim.cmd('Lspsaga peek_definition')
        vim.defer_fn(function()
            vim.cmd('normal! zz')
        end, 100)
    end, desc = 'Peek Definition' },
    { 'gr', '<cmd>Lspsaga rename<CR>', desc = 'Rename' },
    { 'ga', '<cmd>Lspsaga code_action<CR>', desc = 'Code Action' },
    { 'gi', '<cmd>Lspsaga finder<CR>', desc = 'Finder (Impl/Def/Ref)' },
    { 'ge', '<cmd>Lspsaga show_line_diagnostics<CR>', desc = 'Show Line Diagnostics' },
    { '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', desc = 'Previous Diagnostic' },
    { ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', desc = 'Next Diagnostic' },
    { '<C-k>', '<cmd>Lspsaga hover_doc<CR>', desc = 'Hover Doc' },
    { '<C-t>', '<cmd>Lspsaga term_toggle<CR>', mode = { 'n', 't' }, desc = 'Terminal Toggle' },
    { '<leader>c', '<cmd>Lspsaga outline<CR>', desc = 'Outline Toggle' },
  },
}
