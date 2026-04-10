return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- パーサーのインストール（旧 ensure_installed の代替）
    require('nvim-treesitter').install({
      "lua", "vim", "vimdoc", "javascript", "typescript", "python", "c", "cpp",
      "bash", "markdown", "markdown_inline", "json", "yaml", "html", "css",
      "go", "gomod", "gosum", "templ",
    })

    -- ハイライト有効化（Neovim ビルトイン API）
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- プラグイン読み込み時点で既に開いているバッファにも適用
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        pcall(vim.treesitter.start, buf)
      end
    end
  end,
}
