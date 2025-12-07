local class = require("class")

---@class rizu.ReplayPlayer
---@operator call: rizu.ReplayPlayer
local ReplayPlayer = class()

---@param events rizu.ReplayEvent[]
function ReplayPlayer:new(events)
	self.events = events
	self.offset = 0
end

---@param time number
---@return number?
---@return rizu.ReplayEvent?
function ReplayPlayer:play(time)
	local event = self.events[self.offset + 1]
	if not event then
		return
	end

	local event_time = event[1]
	if time < event_time then
		return
	end

	self.offset = self.offset + 1

	return event_time, event[2]
end

return ReplayPlayer
