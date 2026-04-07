return {
  'easymotion/vim-easymotion',
  keys = {
    { '<Leader>j', '<Plug>(easymotion-bd-w)', mode = '', desc = 'EasyMotion: Word' },
    { '<Leader>J', '<Plug>(easymotion-overwin-w)', desc = 'EasyMotion: Overwin word' },
    { '<Leader>l', '<Plug>(easymotion-bd-jk)', mode = '', desc = 'EasyMotion: Line' },
    { '<Leader>l', '<Plug>(easymotion-overwin-line)', desc = 'EasyMotion: Overwin line' },
    { '<Leader>k', '<Plug>(easymotion-bd-f)', mode = '', desc = 'EasyMotion: Find char' },
    { '<Leader>k', '<Plug>(easymotion-overwin-f)', desc = 'EasyMotion: Overwin find' },
  },
  config = function()
    vim.g.mapleader = " "
  end,
}