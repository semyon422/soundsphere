local ModifierEncoder = require("sphere.models.ModifierEncoder")

local Modifiers = {}

---@param t table
---@return string
function Modifiers.encode(t)
	if not t[1] then
		return ""
	end
	return ModifierEncoder:encode(t)
end

---@param t string
---@return table
function Modifiers.decode(t)
	if t == "" then
		return {}
	end
	return ModifierEncoder:decode(t)
end

return Modifiers
