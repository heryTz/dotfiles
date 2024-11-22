return {
	"github/copilot.vim",
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken",
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

			vim.keymap.set("n", "<leader>ai", chat.toggle, { noremap = true, silent = true })
		end,
	},
}
