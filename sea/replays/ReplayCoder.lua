local json = require("json")
local table_util = require("table_util")
local mime = require("mime")
local Replay = require("sea.replays.Replay")
local ReplayEvents = require("sea.replays.ReplayEvents")
local ReplayFrames = require("rizu.engine.replay.ReplayFrames")

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

	local events = mime.unb64(obj.frames)
	if not events then
		return nil, "can't unb64"
	end

	if obj.version == 1 then
		obj.frames = ReplayEvents.decode(events)
	elseif obj.version == 2 then
		obj.frames = ReplayFrames.decode(events)
	end

	setmetatable(obj, Replay)

	return obj
end

---@param replay sea.Replay
---@return string?
---@return string?
function ReplayCoder.encode(replay)
	local obj = table_util.copy(replay)
	---@cast obj -sea.Replay

	local frames = ""
	if obj.version == 1 then
		frames = ReplayEvents.encode(replay.frames)
	elseif obj.version == 2 then
		frames = ReplayFrames.encode(replay.frames)
	end
	obj.frames = mime.b64(frames)

	---@type boolean, string
	local ok, str = pcall(json.encode, obj)
	if not ok then
		return nil, str
	end

	return str
end

return ReplayCoder
