return {
  'justinmk/vim-sneak',
  keys = { 'f', 'F', 't', 'T', 's', 'S' },
  config = function()
    vim.api.nvim_set_keymap("n", "f", "<Plug>Sneak_s", {})
    vim.api.nvim_set_keymap("n", "F", "<Plug>Sneak_S", {})
    vim.api.nvim_set_keymap("n", "t", "<Plug>Sneak_t", {})
    vim.api.nvim_set_keymap("n", "T", "<Plug>Sneak_T", {})
    
    vim.g['sneak#use_ic_scs'] = 1
    vim.g['sneak#label'] = 2
  end,
}
