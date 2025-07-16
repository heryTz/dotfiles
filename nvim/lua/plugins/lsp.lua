local lsp = {
	"lua_ls",
	"tailwindcss",
	"eslint",
	"cssls",
	"css_variables",
	"gopls",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		require("custom-plugins.ts_lsp").setup({
			capabilities = capabilities,
		})

		for _, lsp_name in ipairs(lsp) do
			vim.lsp.enable(lsp_name)
			vim.lsp.config(lsp_name, {
				capabilities = capabilities,
			})
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "Goto Definition" })
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
}
