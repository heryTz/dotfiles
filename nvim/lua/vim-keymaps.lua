vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "<leader>wh", ":split<CR>", { silent = true })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { silent = true })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { silent = true })
