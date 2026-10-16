vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
})

local treesitter = require("nvim-treesitter")
treesitter.setup()

treesitter.install({
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
	"go",
	"c",
	"astro",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		if pcall(vim.treesitter.start) then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo.foldmethod = "expr"
		end
	end,
})
