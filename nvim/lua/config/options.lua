-- options
vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s,[,],<,>"
vim.opt.backspace = "indent,eol,start"
vim.opt.ambiwidth = "single"
vim.opt.wildmenu = true
vim.opt.ignorecase = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.showcmd = true
vim.opt.hlsearch = true
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.backupdir = os.getenv("HOME") .. '/.vim/backup'
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.termguicolors = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.wrap = false
vim.opt.nrformats = "bin,hex"
vim.opt.startofline = false
vim.opt.formatoptions:remove('t')
vim.opt.formatoptions:append('mM')
vim.opt.textwidth = 100
vim.opt.wrap = true
vim.opt.list = true
vim.opt.listchars = { tab = '>>', trail = '-', nbsp = '+' }
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.verbose = 0

-- Include directories for file navigation
vim.opt.path:append('**')
vim.opt.suffixesadd:append('.lua')
vim.opt.suffixesadd:append('.go')
vim.opt.suffixesadd:append('.py')
vim.opt.suffixesadd:append('.js')
vim.opt.suffixesadd:append('.ts')

-- Folding (Treesitter-based)
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Treesitter ロード後に fold を再計算
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    vim.schedule(function()
      if vim.bo.buftype ~= 'terminal' and vim.wo.foldmethod == 'expr' then
        vim.cmd('normal! zx')
      end
    end)
  end,
})

-- templ filetype detection
vim.filetype.add({
  extension = {
    templ = "templ",
  },
})
