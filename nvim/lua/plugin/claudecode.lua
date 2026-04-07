return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  event = 'VeryLazy',
  config = function()
    -- Setup the plugin first
    require("claudecode").setup()

    -- Custom function to send visual selection to Claude Code in tmux pane
    local function send_to_claude_tmux()
      -- Get visual selection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.fn.getline(start_pos[2], end_pos[2])

      -- Handle partial line selection for first and last line
      if #lines > 0 then
        -- Get the column positions for visual selection
        local start_col = start_pos[3]
        local end_col = end_pos[3]

        if #lines == 1 then
          -- Single line selection
          lines[1] = string.sub(lines[1], start_col, end_col)
        else
          -- Multi-line selection
          lines[1] = string.sub(lines[1], start_col)
          lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
      end

      local selected_text = table.concat(lines, '\n')

      -- Get relative file path
      local file_path = vim.fn.expand('%:.')

      -- Get file type for code block
      local filetype = vim.bo.filetype
      -- Default to empty string if filetype is not set
      local lang = filetype ~= '' and filetype or ''

      -- Format message in the requested format:
      -- @path
      -- ```lang
      -- code
      -- ```
      local message = string.format("@%s\n```%s\n%s\n```", file_path, lang, selected_text)

      -- Check if we're in a tmux session
      local tmux_check = vim.fn.system('echo $TMUX')
      if tmux_check == '' or tmux_check == '\n' then
        vim.notify('Not in a tmux session', vim.log.levels.WARN)
        return
      end

      -- Write to temporary file to handle multi-line content properly
      local tmpfile = vim.fn.tempname()
      vim.fn.writefile(vim.split(message, '\n'), tmpfile)

      -- Load to tmux buffer and paste to next pane
      local load_result = vim.fn.system(string.format('tmux load-buffer %s', vim.fn.shellescape(tmpfile)))
      if vim.v.shell_error ~= 0 then
        vim.notify('Failed to load tmux buffer: ' .. load_result, vim.log.levels.ERROR)
        vim.fn.delete(tmpfile)
        return
      end

      -- Paste to right pane
      -- You can change the target pane as needed:
      -- {right} = right pane
      -- {left} = left pane
      -- {up} = up pane
      -- {down} = down pane
      local paste_result = vim.fn.system('tmux paste-buffer -t {right}')
      if vim.v.shell_error ~= 0 then
        vim.notify('Failed to paste to tmux pane: ' .. paste_result, vim.log.levels.ERROR)
      else
        vim.notify('Sent to Claude Code in tmux pane', vim.log.levels.INFO)
      end

      -- Cleanup
      vim.fn.delete(tmpfile)
    end

    -- Yank visual selection as code block to clipboard
    local function yank_as_codeblock()
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.fn.getline(start_pos[2], end_pos[2])

      if #lines > 0 then
        local start_col = start_pos[3]
        local end_col = end_pos[3]
        if #lines == 1 then
          lines[1] = string.sub(lines[1], start_col, end_col)
        else
          lines[1] = string.sub(lines[1], start_col)
          lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
      end

      local selected_text = table.concat(lines, '\n')
      local file_path = vim.fn.expand('%:.')
      local filetype = vim.bo.filetype
      local lang = filetype ~= '' and filetype or ''

      local message = string.format("@%s\n```%s\n%s\n```", file_path, lang, selected_text)
      vim.fn.setreg('+', message)
      vim.notify('Yanked as code block to clipboard', vim.log.levels.INFO)
    end

    -- Create user commands
    vim.api.nvim_create_user_command('ClaudeCodeSendToTmux', send_to_claude_tmux, {
      range = true,
      desc = 'Send visual selection to Claude Code in tmux pane'
    })
    vim.api.nvim_create_user_command('ClaudeCodeYankCodeBlock', yank_as_codeblock, {
      range = true,
      desc = 'Yank visual selection as code block to clipboard'
    })
  end,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    -- Custom visual mode commands
    { "<leader>as", ":<C-u>ClaudeCodeSendToTmux<cr>", mode = "v", desc = "Send to Claude in tmux" },
    { "<leader>ay", ":<C-u>ClaudeCodeYankCodeBlock<cr>", mode = "v", desc = "Yank as code block" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
