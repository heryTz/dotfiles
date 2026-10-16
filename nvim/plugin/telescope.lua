vim.pack.add({
	"folke/trouble.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	{
		src = "https://github.com/nvim-telescope/telescope.nvim",
		-- version = vim.version.range("0.2.1"),
		version = "v0.2.2",
	},
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
})

local telescope = require("telescope")
local open_with_trouble = require("trouble.sources.telescope").open

telescope.setup({
	pickers = {
		find_files = {
			find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
		},
	},
	defaults = {
		mappings = {
			i = { ["<c-t>"] = open_with_trouble },
			n = { ["<c-t>"] = open_with_trouble },
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})
telescope.load_extension("ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader> ", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)
vim.keymap.set("", "<leader>fm", require("multigrep").multigrep)
vim.keymap.set("n", "<leader>fp", function()
	builtin.find_files({
		---@diagnostic disable-next-line: param-type-mismatch
		cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "pack/core/opt"),
	})
end)
