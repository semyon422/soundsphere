local class = require("class")
local serpent = require("serpent")
local json = require("json")
local md5 = require("md5")

local ModifierEncoder = class()

---@param config table
---@return string
function ModifierEncoder:encode(config)
	return json.encode(config)
end

---@param config table
---@return string
function ModifierEncoder:hash(config)
	return md5.sumhexa(serpent.line(config, {sortkeys = true, comment = false, compact = true}))
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
	local ok, err = pcall(json.decode, s)
	if ok then
		return err
	end

	local config = {}
	for id, version, value in s:gmatch("(%d+):([^;^,]+),([^;^,]+)") do
		table.insert(config, {
			id = tonumber(id),
			version = tonumber(version),
			value = decodeValue(value),
		})
	end
	return config
end

return ModifierEncoder
