local lsp = {
	"lua_ls",
	"tailwindcss",
	"eslint",
	"cssls",
	"css_variables",
	"gopls",
	-- "tsls",
	-- "vtsls",
	-- "vue_ls",
	-- "jsonls",
	-- "html",
	-- "phpactor",
	-- "prismals",
	-- "helm_ls",
	-- "yamlls",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		local vtsls_config = {
			capabilities = capabilities,
			settings = {
				vtsls = {
					tsserver = {
						globalPlugins = {
							{
								name = "@vue/typescript-plugin",
								location = "/usr/local/lib/node_modules/@vue/language-server",
								languages = { "vue" },
								configNamespace = "typescript",
							},
						},
					},
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		}

		local vue_ls_config = {
			capabilities = capabilities,
			on_init = function(client)
				client.handlers["tsserver/request"] = function(_, result, context)
					local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
					if #clients == 0 then
						vim.notify(
							"Could not find `vtsls` lsp client, `vue_ls` would not work without it.",
							vim.log.levels.ERROR
						)
						return
					end
					local ts_client = clients[1]

					local param = unpack(result)
					local id, command, payload = unpack(param)
					ts_client:exec_cmd({
						title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
						command = "typescript.tsserverRequest",
						arguments = {
							command,
							payload,
						},
					}, { bufnr = context.bufnr }, function(_, r)
						local response_data = { { id, r.body } }
						---@diagnostic disable-next-line: param-type-mismatch
						client:notify("tsserver/response", response_data)
					end)
				end
			end,
		}

		vim.lsp.config("vtsls", vtsls_config)
		vim.lsp.config("vue_ls", vue_ls_config)
		vim.lsp.enable({ "vtsls", "vue_ls" })

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
