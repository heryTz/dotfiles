local lint_util = require("util._lint")

return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {}

		if lint_util.has_eslint_config() then
			lint.linters_by_ft.typescript = { "eslint_d" }
			lint.linters_by_ft.typescriptreact = { "eslint_d" }
			lint.linters_by_ft.javascript = { "eslint_d" }
			lint.linters_by_ft.javascriptreact = { "eslint_d" }
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			-- pattern = {},
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting" })
	end,
}
