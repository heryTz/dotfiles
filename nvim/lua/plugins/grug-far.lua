return {
	"MagicDuck/grug-far.nvim",
	config = function()
		local grug = require("grug-far")
		grug.setup({})

		vim.keymap.set("n", "<leader>sr", function()
			grug.toggle_instance({ instanceName = "far", staticTitle = "Search and Replace" })
		end, { desc = "Search and Replace", silent = true })
	end,
}
