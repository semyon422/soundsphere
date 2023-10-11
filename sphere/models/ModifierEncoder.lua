local class = require("class")
local ModifierModel = require("sphere.models.ModifierModel")

local Modifiers = ModifierModel.Modifiers
local ModifiersById = ModifierModel.ModifiersById

local ModifierEncoder = class()

---@param config table
---@return string
function ModifierEncoder:encode(config)
	local t = {}
	for _, modifierConfig in ipairs(config) do
		local id = Modifiers[modifierConfig.name]
		if id then
			local encoded = ("%d:%d,%s"):format(
				Modifiers[modifierConfig.name],
				modifierConfig.version,
				modifierConfig.value
			)
			table.insert(t, encoded)
		end
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
		id = tonumber(id)
		local mod = ModifiersById[id]
		if mod then
			local mconfig = {
				name = mod.name,
				version = tonumber(version),
				value = decodeValue(value),
			}
			table.insert(config, mconfig)
		end
	end
	return config
end

return ModifierEncoder
