vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/neogitorg/neogit",
})

require("neogit").setup({
  disable_context_highlighting = true,
  highlight = {
    italic = false,
  },
  integrations = {
    diffview = true,
  },
})

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { silent = true })
