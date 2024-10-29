vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to the left pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to the bottom pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to the top pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to the right pane" })

vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Horizontal Split", silent = true })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Vertical Split", silent = true })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { desc = "Close Pane", silent = true })
