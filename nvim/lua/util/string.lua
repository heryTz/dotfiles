local M = {}

--- Convert a string to camelcase
--- @param str string
--- @return string
M.toPascalCase = function(str)
	str = string.gsub(str, "%W", " ")
	str = string.gsub(str, "(%s+%l)", function(word)
		return string.upper(string.sub(word, 2))
	end)
	str = string.gsub(str, "%s+", "")
	str = string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
	return str
end

return M
