return {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "main",
	dependencies = {
		{ "github/copilot.vim" },
		{ "nvim-lua/plenary.nvim" },
	},
	build = "make tiktoken",
	init = function()
		vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
	end,
	config = function()
		local chat = require("CopilotChat")

		chat.setup({
			mappings = {
				reset = {
					normal = "<C-x>",
					insert = "<C-x>",
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>aiv", chat.toggle, { noremap = true, silent = true })
		vim.keymap.set({ "n", "v" }, "<leader>aif", function()
			chat.open({
				window = {
					layout = "float",
				},
			})
		end, { silent = true })
	end,
}
