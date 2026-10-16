vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/kdheepak/lazygit.nvim",
})

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { silent = true })
