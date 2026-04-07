return {
  'numToStr/Comment.nvim',
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require('Comment').setup({
      -- コメントの前後にスペースを追加
      padding = true,
      
      -- 現在行のコメントトグル
      toggler = {
        -- 行コメント
        line = 'gcc',
        -- ブロックコメント
        block = 'gbc',
      },
      
      -- オペレーターモードでのマッピング
      opleader = {
        -- 行コメント
        line = 'gc',
        -- ブロックコメント
        block = 'gb',
      },
      
      -- 追加のマッピング
      extra = {
        -- 上にコメント行を追加
        above = 'gcO',
        -- 下にコメント行を追加
        below = 'gco',
        -- 行末にコメントを追加
        eol = 'gcA',
      },
      
      -- Treesitterとの統合を有効化
      pre_hook = function(ctx)
        local ok, ts_comment = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
        if ok then
          return ts_comment.create_pre_hook()(ctx)
        end
      end,
    })
  end,
}