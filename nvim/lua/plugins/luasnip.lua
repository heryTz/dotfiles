return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local ls = require("luasnip")
		require("luasnip.loaders.from_vscode").lazy_load()

		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-H>", function()
			ls.jump(-1)
		end, { silent = true })

		-- local s = ls.snippet
		-- local t = ls.text_node
		-- local i = ls.insert_node
		--
		-- ls.snippets = {
		-- 	all = {
		-- 		s("hery", {
		-- 			t('Hello from "hery"'),
		-- 			i(1),
		-- 			t("world"),
		-- 		}),
		-- 	},
		-- }
	end,
}
