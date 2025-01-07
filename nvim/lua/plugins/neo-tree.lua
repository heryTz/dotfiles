return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "<leader>e", ":Neotree toggle<CR>", desc = "NeoTree reveal", silent = true },
	},
	opts = {
		filesystem = {
			follow_current_file = {
				enabled = true,
			},
			filtered_items = {
				hide_dotfiles = false,
				hide_by_name = {
					".git",
					".DS_Store",
					".swc",
				},
				always_show_by_pattern = {
					".env*",
					".dockerignore",
					".husky",
					".prettierignore",
				},
			},
		},
	},
}
