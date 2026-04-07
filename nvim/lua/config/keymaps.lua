-- keymap
vim.g.mapleader = " " -- vim.api.nvim_set_keymap('n', '<leader><leader>', ':<C-u>e ./<CR>', {noremap = true})

-- vim.api.nvim_set_keymap('n', '<leader>r', ':<C-u>e ./<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':<C-u>w<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>q', ':<C-u>bd<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-n>', ':<C-u>bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':<C-u>bprevious<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-W>=', ':<C-u>resize +10<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-W>\\', ':<C-u>vertical split<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-W>-', ':<C-u>horizontal split<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-W>>', ':<C-u>vertical resize +10<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-W><', ':<C-u>vertical resize -10<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<ESC><ESC>', ':nohlsearch<CR>', { silent = true })
vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { silent = true })

-- like a mac keymap -----------------------------------------------------------
vim.api.nvim_set_keymap('i', '<C-a>', '<Home>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-e>', '<End>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-f>', '<Right>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-b>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true })

-- files
vim.api.nvim_set_keymap("", ",q", ":<C-u>e $HOME/.config/nvim/init.lua<CR>", { silent = true })
vim.api.nvim_set_keymap("", ",w", ":<C-u>e $HOME/.zshrc<CR>", { silent = true })

-- change current directory to the file directory
vim.api.nvim_set_keymap("n", '<leader><leader>', ':<C-u>cd %:h<CR>', {noremap = true})

-- terminal
vim.api.nvim_set_keymap("n", "tt", ":<C-u>belowright new<CR>:<C-u>terminal<CR>", {noremap = true})

-- duplicate line
vim.api.nvim_set_keymap('n', 'yc', 'yy<cmd>normal gcc<CR>p', { noremap = true })

-- Yank file path from project root
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:~:.')
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Yank file path (relative)' })

-- fold toggle
vim.keymap.set('n', '<CR>', function()
  if vim.fn.foldlevel('.') > 0 then
    vim.cmd('normal! za')
  end
end, { silent = true, desc = 'Toggle fold' })

-- move line
vim.keymap.set({ "n", "v" }, "H", "^",  { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "L", "$",  { noremap = true, silent = true })

-- oil.nvim
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- File jump mappings
vim.api.nvim_set_keymap('n', 'gf', 'gf', { noremap = true, desc = "Go to file under cursor" })

-- Toggle terminal transparency (Neovim + WezTerm)
vim.g.transparent_enabled = true
vim.keymap.set('n', '<leader>tt', function()
  vim.g.transparent_enabled = not vim.g.transparent_enabled
  local bg = vim.g.transparent_enabled and 'NONE' or '#1a1b26'
  vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = bg })
  vim.api.nvim_set_hl(0, 'SignColumn', { bg = bg })
  -- Send signal to WezTerm (MQ== is base64 for "1")
  io.write('\x1b]1337;SetUserVar=toggle_opacity=MQ==\x07')
  vim.notify('Transparency: ' .. (vim.g.transparent_enabled and 'ON' or 'OFF'), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = 'Toggle transparency' })
