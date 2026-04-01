return {
	{
		"ojroques/nvim-bufdel",
		config = function()
			require("bufdel").setup({
				next = "tabs",
				quit = false,
			})
			vim.keymap.set("n", "<leader>bd", ":BufDel<CR>", { silent = true })
		end,
	},
	{
		"akinsho/bufferline.nvim",
		depedencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("bufferline").setup({
				options = {
					offsets = {
						{
							filetype = "neo-tree",
							text = "File Explorer",
							text_align = "left",
							highlight = "Directory",
							separator = true,
						},
					},
				},
			})

			vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })
			vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
			vim.keymap.set(
				"n",
				"<leader>bl",
				":BufferLineCloseRight<CR>",
				{ silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>bh",
				":BufferLineCloseLeft<CR>",
				{ silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>bo",
				":BufferLineCloseOthers<CR>",
				{ silent = true }
			)
		end,
	},
}
