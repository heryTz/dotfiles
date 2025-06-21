local M = {}

M.setup = function()
	vim.lsp.config("eslint", {
		root_dir = require("lspconfig.util").find_git_ancestor,
	})
end

return M
