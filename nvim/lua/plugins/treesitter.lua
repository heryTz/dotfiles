return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"javascript",
				"html",
				"typescript",
				"tsx",
				"php",
				"bash",
				"json",
				"css",
				"php",
				"prisma",
				"helm",
				"gotmpl",
			},
			ignore_install = {},
			auto_install = true,
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
			modules = {},
		})
	end,
}
