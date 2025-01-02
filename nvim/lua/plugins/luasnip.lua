return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local ls = require("luasnip")
		require("../snippets/js")
		require("luasnip.loaders.from_vscode").lazy_load()

		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-H>", function()
			ls.jump(-1)
		end, { silent = true })
	end,
}
