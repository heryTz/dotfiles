local lsp_lists = {
	"lua_ls",
	"ts_ls",
	"jsonls",
	"tailwindcss",
	"cssls",
	"css_variables",
	"html",
	"eslint",
	"phpactor",
	"prismals",
	"helm_ls",
	"yamlls",
	"gopls",
}

local mason_tool = {
	"prettierd",
	"stylua",
	"helm-ls",
	"yamlls",
}

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = lsp_lists,
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = mason_tool,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			for _, lsp in ipairs(lsp_lists) do
				lspconfig[lsp].setup({
					capabilities = capabilities,
				})
			end

			-- https://github.com/neovim/nvim-lspconfig/issues/1427#issuecomment-980842735
			lspconfig.eslint.setup({
				capabilities = capabilities,
				root_dir = require("lspconfig.util").find_git_ancestor,
			})

			lspconfig.helm_ls.setup({
				settings = {
					["helm-ls"] = {
						yamlls = {
							path = "yaml-language-server",
						},
					},
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					vim.keymap.set(
						"n",
						"gd",
						require("telescope.builtin").lsp_definitions,
						{ desc = "Goto Definition" }
					)
					vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "Goto References" })
					vim.keymap.set(
						"n",
						"gt",
						require("telescope.builtin").lsp_type_definitions,
						{ desc = "Goto Type Definition" }
					)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
					vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
					vim.keymap.set(
						"n",
						"<leader>sym",
						require("telescope.builtin").lsp_document_symbols,
						{ desc = "Document Symbols" }
					)

					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client == nil then
						return
					end

					if client.supports_method("textDocument/rename") then
						vim.keymap.set("n", "<leader>br", vim.lsp.buf.rename, { desc = "Rename" })
					end

					if client.supports_method("textDocument/implementation") then
						vim.keymap.set(
							"n",
							"gI",
							require("telescope.builtin").lsp_implementations,
							{ desc = "Goto Implementation" }
						)
					end

					if client.supports_method("textDocument/declaration") then
						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
					end
				end,
			})
		end,
	},
}
