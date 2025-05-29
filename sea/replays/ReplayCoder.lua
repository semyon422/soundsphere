local json = require("json")
local table_util = require("table_util")
local mime = require("mime")
local Replay = require("sea.replays.Replay")

---@class sea.ReplayCoder
local ReplayCoder = {}

---@param s string
---@return sea.Replay?
---@return string?
function ReplayCoder.decode(s)
	---@type boolean, table
	local ok, obj = pcall(json.decode, s)
	if not ok then
		return nil, "invalid json: " .. obj
	end

	local events = mime.unb64(obj.events)
	if not events then
		return nil, "can't unb64"
	end

	obj.events = events
	setmetatable(obj, Replay)

	return obj
end

---@param replay sea.Replay
---@return string?
---@return string?
function ReplayCoder.encode(replay)
	local obj = table_util.copy(replay)
	obj.events = mime.b64(obj.events)

	---@type boolean, string
	local ok, str = pcall(json.encode, obj)
	if not ok then
		return nil, str
	end

	return str
end

return ReplayCoder
