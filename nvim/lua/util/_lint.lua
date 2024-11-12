local M = {}

M.has_eslint_config = function()
	local root_files = { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.mjs", "package.json" }
	for _, filename in pairs(root_files) do
		if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. filename) == 1 then
			if filename == "package.json" then
				local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
				if package_json.devDependencies and package_json.devDependencies["eslint"] then
					return true
				elseif package_json.dependencies and package_json.dependencies["eslint"] then
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

return M
