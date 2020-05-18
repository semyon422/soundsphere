local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")

local Replay = Class:new()

Replay.construct = function(self)
	self.observable = Observable:new()
	self.events = {}
	self.eventOffset = 0
end

Replay.receive = function(self, event)
	if not event.virtual then
		return
	end

	local events = self.events
	events[#events + 1] = event
end

Replay.reset = function(self)
	self.eventOffset = 0
end

Replay.step = function(self)
	self.eventOffset = math.min(self.eventOffset + 1, #self.events)
end

Replay.getNextEvent = function(self)
	return self.events[self.eventOffset + 1]
end

return Replay
