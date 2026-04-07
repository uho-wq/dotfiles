return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    { '<leader>gf', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit Current File' },
  },
  config = function()
    -- Configure lazygit to use custom config
    vim.g.lazygit_use_custom_config_file_path = 1
    vim.g.lazygit_config_file_path = vim.fn.expand('~/.config/lazygit/config.yml')

    -- Completely disable floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.0
    vim.g.lazygit_floating_window_winblend = 0
    vim.g.lazygit_floating_window_use_plenary = 0

    -- Override LazyGit command to open in current buffer instead of floating
    vim.api.nvim_create_user_command('LazyGit', function()
      vim.cmd('tabnew')
      vim.cmd('terminal lazygit')
      vim.cmd('startinsert')
    end, { desc = 'Open LazyGit in current buffer' })
    
    -- Create autocmd to handle file opening from lazygit
    vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
      pattern = {'*'},
      callback = function()
        if vim.bo.filetype == 'lazygit' then
          -- Set terminal options for better lazygit experience
          vim.wo.number = false
          vim.wo.relativenumber = false
          vim.wo.signcolumn = 'no'
        end
      end,
    })
    
    -- Alternative commands for different window layouts
    vim.api.nvim_create_user_command('LazyGitSplit', function()
      vim.cmd('split')
      vim.cmd('terminal lazygit')
      vim.cmd('startinsert')
    end, { desc = 'Open LazyGit in a split' })
    
    vim.api.nvim_create_user_command('LazyGitVSplit', function()
      vim.cmd('vsplit')
      vim.cmd('terminal lazygit')
      vim.cmd('startinsert')
    end, { desc = 'Open LazyGit in a vertical split' })
    
    vim.api.nvim_create_user_command('LazyGitCurrentFile', function()
      local file = vim.fn.expand('%:p')
      if file == '' then
        vim.notify('No file in current buffer', vim.log.levels.WARN)
        return
      end
      vim.cmd('tabnew')
      vim.cmd('terminal lazygit -f ' .. vim.fn.shellescape(file))
      vim.cmd('startinsert')
    end, { desc = 'Open LazyGit for current file' })
  end,
}