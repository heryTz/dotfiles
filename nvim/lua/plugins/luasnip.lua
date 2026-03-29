return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local ls = require("luasnip")
		local str = require("../util/string")
		require("../snippets/js")
		require("luasnip.loaders.from_vscode").lazy_load()

		---load project snippet
		local project_root = vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
		if project_root ~= nil then
			local project_luasnip = project_root .. "/.nvim/luasnip"
			if vim.fn.isdirectory(project_luasnip) == 1 then
				---@type string[]
				local files = vim.fn.glob(project_luasnip .. "/*.lua", false, true)
				for _, file in ipairs(files) do
					local file_module = dofile(file)
					if file_module == nil or file_module.load == nil then
						vim.notify(file .. ' does not have "load" method', vim.log.levels.ERROR, {
							title = "Project Snippet",
						})
					else
						file_module.load(ls, str)
					end
				end
			end

			local project_vscode_snip = project_root .. "/.vscode/snippets"
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { project_vscode_snip } })
		end

		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })
		vim.keymap.set({ "i", "s" }, "<C-H>", function()
			ls.jump(-1)
		end, { silent = true })
	end,
}
