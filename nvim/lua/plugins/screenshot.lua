return {
	"michaelrommel/nvim-silicon",
	cmd = "Silicon",
	main = "nvim-silicon",
	opts = {},
	config = function()
		local silicon = require("nvim-silicon")
		silicon.setup({
			font = "JetBrainsMono Nerd Font Mono=34",
			theme = "Dracula",
			tab_width = 2,
			window_title = function()
				return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t")
			end,
			-- TODO how to add watermark ?
			-- watermark = {
			-- 	text = "Hery Nirintsoa",
			-- 	color = "#222",
			-- 	style = "bold",
			-- },
		})
	end,
}
