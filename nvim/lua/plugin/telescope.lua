return {
  'nvim-telescope/telescope.nvim',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  cmd = { 'Telescope' },
  keys = {
    { '<leader>e', function() require('telescope.builtin').find_files({ hidden = true }) end, desc = 'Telescope find files (including hidden)' },
    { '<leader>E', function() require('telescope.builtin').git_files() end, desc = 'Telescope git files' },
    { '<leader>p', function() require('telescope.builtin').live_grep() end, desc = 'Telescope live grep' },
    { '<leader>b', function() require('telescope.builtin').buffers() end, desc = 'Telescope buffers' },
    { '<leader>h', function() require('telescope.builtin').oldfiles() end, desc = 'Telescope oldfiles' },
    { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Telescope help tags' },
    { '<leader>fr', function() require('telescope.builtin').registers() end, desc = 'Telescope registers' },
    { '<leader>gs', function() require('telescope.builtin').git_status() end, desc = 'Telescope git status' },
    { '<leader>gc', function() require('telescope.builtin').git_commits() end, desc = 'Telescope git commits' },
  },
  config = function()
    require('telescope').setup({
      defaults = {
        file_ignore_patterns = { "^%.git/", "^%.github/" },
        mappings = {
          i = {
            ['<C-j>'] = require('telescope.actions').move_selection_next,
            ['<C-k>'] = require('telescope.actions').move_selection_previous,
          },
        },
      },
    })
  end,
}
