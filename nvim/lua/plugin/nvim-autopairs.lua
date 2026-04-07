return {
  'windwp/nvim-autopairs',
  event = 'VeryLazy',
  config = function()
    local npairs = require("nvim-autopairs")
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    npairs.setup({
      check_ts = true,                -- treesitterとの連携
      ts_config = {
        lua = {'string'},             -- luaの文字列内では無効
        javascript = {'template_string'}, -- JSのテンプレート文字列内では無効
        java = false,                 -- javaでは無効
      },
      disable_filetype = { "TelescopePrompt" }, -- 無効にするファイルタイプ
      fast_wrap = {                   -- 括弧の高速ラップ
        map = '<M-e>',                -- Alt+e でラップ
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey='Comment'
      },
      enable_check_bracket_line = true,  -- 行末の括弧チェック
      ignored_next_char = "[%w%.]",      -- 次の文字が単語や.の場合は無視
    })

    -- 特定の括弧ペアを追加
    npairs.add_rules({
      -- スペースを自動挿入
      Rule(' ', ' ')
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
      Rule('( ', ' )')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
      Rule('{ ', ' }')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
      Rule('[ ', ' ]')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']'),

      -- =の後にスペースを入れる（無効化）
      -- Rule('=', '')
      --   :with_pair(cond.not_inside_quote())
      --   :with_pair(function(opts)
      --     local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
      --     if last_char:match('[%w%=%s]') then
      --       return true
      --     end
      --     return false
      --   end)
      --   :replace_endpair(function(opts)
      --     local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
      --     local next_char = opts.line:sub(opts.col, opts.col)
      --     next_char = next_char == ' ' and '' or ' '
      --     if prev_2char:match('%w$') then
      --       return ' ' .. next_char
      --     end
      --     return next_char
      --   end)
      --   :set_end_pair_length(0)
      --   :with_move(cond.none())
      --   :with_del(cond.none()),
    })
  end,
}
