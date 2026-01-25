local class = require("class")

---@class rizu.ReplayPlayer
---@operator call: rizu.ReplayPlayer
local ReplayPlayer = class()

---@param frames rizu.ReplayFrame[]
function ReplayPlayer:new(frames)
	self.frames = frames
	self.offset = 0
end

---@param time number
---@return rizu.ReplayFrame?
function ReplayPlayer:play(time)
	local frame = self.frames[self.offset + 1]
	if not frame then
		return
	end

	if time < frame.time then
		return
	end

	self.offset = self.offset + 1

	return frame
end

return ReplayPlayer
