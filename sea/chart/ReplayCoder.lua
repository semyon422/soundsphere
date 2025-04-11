local class = require("class")
local json = require("json")
local ReplayConverter = require("sphere.models.ReplayModel.ReplayConverter")

---@class sea.ReplayCoder
---@operator call: sea.ReplayCoder
local ReplayCoder = class()

---@param s string
---@return sea.Replay?
---@return string?
function ReplayCoder.decode(s)
	---@type boolean, table
	local ok, obj = pcall(json.decode, s)
	if not ok then
		return nil, "invalid json: " .. obj
	end
	return ReplayConverter:convert(obj)
end

---@param replay sea.Replay
---@return string?
---@return string?
function ReplayCoder.encode(replay)
	---@type boolean, string
	local ok, str = pcall(json.encode, replay)
	if not ok then
		return nil, str
	end
	return str
end

return ReplayCoder
