local class = require("class")

---@class rizu.ReplayRecorder
---@operator call: rizu.ReplayRecorder
local ReplayRecorder = class()

function ReplayRecorder:new()
	---@type rizu.ReplayFrame[]
	self.frames = {}
end

---@param time number
---@param event rizu.VirtualInputEvent
function ReplayRecorder:record(time, event)
	table.insert(self.frames, {
		time = time,
		event = event
	})
end

---@return rizu.ReplayFrame[]
function ReplayRecorder:getFrames()
	return self.frames
end

function ReplayRecorder:clear()
	self.frames = {}
end

return ReplayRecorder
