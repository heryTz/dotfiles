vim.pack.add({
	"https://github.com/ojroques/nvim-bufdel",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/akinsho/bufferline.nvim",
})

require("bufdel").setup({
	next = "tabs",
	quit = false,
})
vim.keymap.set("n", "<leader>bd", ":BufDel<CR>", { silent = true })

require("bufferline").setup()
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<leader>bl", ":BufferLineCloseRight<CR>", { silent = true })
vim.keymap.set("n", "<leader>bh", ":BufferLineCloseLeft<CR>", { silent = true })
vim.keymap.set("n", "<leader>bo", ":BufferLineCloseOthers<CR>", { silent = true })
