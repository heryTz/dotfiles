return {
	settings = {
		gopls = {
			completeUnimported = true,
			staticcheck = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
	--- on_new_config does not exist with nvim lsp native
	--- https://github.com/neovim/neovim/issues/32287#issuecomment-2961170757
	--- @param client vim.lsp.Client
	on_init = function(client)
		if client.root_dir then
			local gopls_config_path = client.root_dir .. "/.nvim/gopls.json"
			local file = io.open(gopls_config_path, "r")
			if file then
				local data = file:read("*a")
				file:close()
				local success, gopls_settings = pcall(vim.json.decode, data)
				if success and gopls_settings then
					-- Fusion des configurations
					client.settings = vim.tbl_deep_extend("force", client.settings or {}, { gopls = gopls_settings })
				end
			end
		end
	end,
}
