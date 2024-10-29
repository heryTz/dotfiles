local lint_util = require("util._lint")

return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")

		if lint_util.has_eslint_config() then
			lint.linters_by_ft = {
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
			}
		end

		vim.api.nvim_create_autocmd({ "BufEnter" }, {
			pattern = { "*.ts", "*.tsx", "*.mts", "*.js", "*.jsx", "*.mjs", "*.lua" },
			callback = function()
				lint.try_lint()
			end,
		})

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting" })
	end,
}
