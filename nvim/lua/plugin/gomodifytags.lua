-- gomodifytags integration for managing Go struct tags
return {
  {
    "fatih/vim-go",
    ft = "go",
    build = ":GoUpdateBinaries",
    config = function()
      -- Disable most of vim-go features, only use tag commands
      vim.g.go_def_mapping_enabled = 0
      vim.g.go_code_completion_enabled = 0
      vim.g.go_fmt_autosave = 1
      vim.g.go_imports_autosave = 0
      vim.g.go_mod_fmt_autosave = 0
      vim.g.go_doc_keywordprg_enabled = 0
      vim.g.go_def_mapping_enabled = 0
      vim.g.go_textobj_enabled = 0
      vim.g.go_list_type = "quickfix"

      -- Only enable tag transformation features
      vim.g.go_addtags_transform = "snakecase"
      vim.g.go_addtags_skip_unexported = 0

      -- Key mappings for tag operations (only in Go files)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          local opts = { noremap = true, silent = true, buffer = true }

          -- Add tags (json by default, can specify others)
          vim.keymap.set("n", "<leader>gat", ":GoAddTags<CR>", opts)
          vim.keymap.set("v", "<leader>gat", ":GoAddTags<CR>", opts)

          -- Remove all tags
          vim.keymap.set("n", "<leader>grt", ":GoRemoveTags<CR>", opts)
          vim.keymap.set("v", "<leader>grt", ":GoRemoveTags<CR>", opts)

          vim.keymap.set("n", "<leader>grj", ":GoRemoveTags json<CR>", opts)
          vim.keymap.set("v", "<leader>grj", ":GoRemoveTags json<CR>", opts)

          vim.keymap.set("n", "<leader>gry", ":GoRemoveTags yaml<CR>", opts)
          vim.keymap.set("v", "<leader>gry", ":GoRemoveTags yaml<CR>", opts)

          vim.keymap.set("n", "<leader>grd", ":GoRemoveTags db<CR>", opts)
          vim.keymap.set("v", "<leader>grd", ":GoRemoveTags db<CR>", opts)

          -- Add all tags (json + yaml + db)
          vim.keymap.set("n", "<leader>gaa", ":GoAddTags json,yaml,db<CR>", opts)
          vim.keymap.set("v", "<leader>gaa", ":GoAddTags json,yaml,db<CR>", opts)

          -- Add json tags
          vim.keymap.set("n", "<leader>gaj", ":GoAddTags json<CR>", opts)
          vim.keymap.set("v", "<leader>gaj", ":GoAddTags json<CR>", opts)

          -- Add yaml tags
          vim.keymap.set("n", "<leader>gay", ":GoAddTags yaml<CR>", opts)
          vim.keymap.set("v", "<leader>gay", ":GoAddTags yaml<CR>", opts)
        end,
      })
    end,
  },
}
