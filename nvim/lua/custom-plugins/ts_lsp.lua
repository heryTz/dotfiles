local M = {}

---Custom setup for Vue and TypeScript LSPs
---The fucking default setup inside `lsp` folder is not working for me.
---It always plain with `Could not find 'vtsls' lsp client, 'vue_ls'.`
---@class Params params
---@field capabilities lsp.ClientCapabilities
M.setup = function(params)
	local capabilities = params.capabilities

	vim.lsp.config("vtsls", {
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
	})

	vim.lsp.config("vue_ls", {
		capabilities = capabilities,
	})

	vim.lsp.enable({ "vtsls", "vue_ls" })
end

return M
