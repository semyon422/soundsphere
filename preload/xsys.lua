---@param mod string
---@return table
local function preload(mod)
	return {
		string = require("string_util")
	}
end

return preload
