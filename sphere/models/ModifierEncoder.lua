local class = require("class")

local ModifierEncoder = class()

---@param config table
---@return string
function ModifierEncoder:encode(config)
	local t = {}
	for _, modifier in ipairs(config) do
		local encoded = ("%d:%d,%s"):format(
			modifier.id,
			modifier.version,
			modifier.value
		)
		table.insert(t, encoded)
	end
	return table.concat(t, ";")
end

---@param s string
---@return any?
local function decodeValue(s)
	if s == "nil" then
		return nil
	end
	return tonumber(s) or s
end

---@param s string
---@return table
function ModifierEncoder:decode(s)
	local config = {}
	for id, version, value in s:gmatch("(%d+):([^;^,]+),([^;^,]+)") do
		local mconfig = {
			id = tonumber(id),
			version = tonumber(version),
			value = decodeValue(value),
		}
		table.insert(config, mconfig)
	end
	return config
end

return ModifierEncoder
