local lsp = {
	"lua_ls",
	"tailwindcss",
	"eslint",
	"cssls",
	"css_variables",
	"gopls",
	"jsonls",
	"biome",
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
				vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions)
				vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references)
				vim.keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions)
				vim.keymap.set("n", "K", function()
					vim.lsp.buf.hover({
						border = "rounded",
					})
				end)
				vim.keymap.set("n", "gK", vim.lsp.buf.signature_help)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
				vim.keymap.set("n", "<leader>gs", require("telescope.builtin").lsp_document_symbols)

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client == nil then
					return
				end

				if client.supports_method("textDocument/rename") then
					vim.keymap.set("n", "<leader>br", vim.lsp.buf.rename)
				end

				if client.supports_method("textDocument/implementation") then
					vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations)
				end

				if client.supports_method("textDocument/declaration") then
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
				end
			end,
		})
	end,
}
