local class = require("class")
local json = require("json")
local stbl = require("stbl")
local md5 = require("md5")

local ModifierEncoder = class()

---@param config table
---@return string
function ModifierEncoder:encode(config)
	local t = {}
	for i, m in ipairs(config) do
		t[i] = {m.id, m.version, m.value}
	end
	return stbl.encode(t)
end

---@param config table
---@return string
function ModifierEncoder:hash(config)
	return md5.sumhexa(stbl.encode(config))
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
	local ok, err = pcall(stbl.decode, s)
	if ok then
		local t = {}
		for i, m in ipairs(err) do
			t[i] = {
				id = m[1],
				version = m[2],
				value = m[3],
			}
		end
		return t
	end
	ok, err = pcall(json.decode, s)
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
