return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '-',
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = 'Open the file manager in nvim\'s working directory',
    },
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
      open_file_in_vertical_split = '<c-v>',
      open_file_in_horizontal_split = '<c-x>',
      open_file_in_tab = '<c-t>',
      grep_in_directory = '<c-s>',
      replace_in_directory = '<c-g>',
      cycle_open_buffers = '<tab>',
      copy_relative_path_to_selected_files = '<c-y>',
      send_to_quickfix_list = '<c-q>',
      change_working_directory = '<c-\\>',
    },
    set_keymappings_function = nil,
    hooks = {},
    integrations = {
      grep_in_directory = function(directory)
        require('telescope.builtin').live_grep({
          search_dirs = { directory },
        })
      end,
      grep_in_selected_files = function(selected_files)
        require('telescope.builtin').live_grep({
          search_dirs = selected_files,
        })
      end,
      replace_in_directory = function(directory)
        require('grug-far').open({
          prefills = {
            paths = directory,
          },
        })
      end,
      replace_in_selected_files = function(selected_files)
        require('grug-far').open({
          prefills = {
            paths = table.concat(selected_files, ' '),
          },
        })
      end,
    },
    highlight_groups = {
      hovered_buffer = { link = 'Visual' },
    },
  },
}
