return {
	"ojroques/nvim-bufdel",
	config = function()
		require("bufdel").setup({
			next = "tabs",
			quit = false,
		})
		vim.keymap.set("n", "<leader>bd", ":BufDel<CR>", { desc = "Delete Buffer", silent = true })
	end,
}
