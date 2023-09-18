---@param mod string
---@return table
local function preload(mod)
	return {
		string = require("aqua.string")
	}
end

return preload
