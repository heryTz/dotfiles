return {
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

		vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Goto Prev Buffer", silent = true })
		vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Goto Next Buffer", silent = true })
		vim.keymap.set(
			"n",
			"<leader>bl",
			":BufferLineCloseRight<CR>",
			{ desc = "Close All Right Buffer", silent = true }
		)
		vim.keymap.set("n", "<leader>bh", ":BufferLineCloseLeft<CR>", { desc = "Close All Left Buffer", silent = true })
		vim.keymap.set("n", "<leader>bo", ":BufferLineCloseOthers<CR>", { desc = "Close All Buffer", silent = true })
		vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Buffer", silent = true })
		vim.keymap.set("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Close All Buffer", silent = true })
	end,
}
