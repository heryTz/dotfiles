local M = {}

M.setup = function()
	vim.lsp.config("gopls", {
		settings = {
			gopls = {
				completeUnimported = true,
				staticcheck = true,
				analyses = {
					unusedparams = true,
				},
			},
		},
		on_new_config = function(new_config, new_root_dir)
			if new_root_dir then
				local gopls_config_path = new_root_dir .. "/.nvim/gopls.json"
				local file = io.open(gopls_config_path, "r")
				if file then
					local data = file:read("*a")
					file:close()
					local success, gopls_settings = pcall(vim.json.decode, data)
					if success and gopls_settings then
						-- Fusion des configurations
						new_config.settings =
							vim.tbl_deep_extend("force", new_config.settings or {}, { gopls = gopls_settings })
					end
				end
			end
		end,
	})
end

return M
