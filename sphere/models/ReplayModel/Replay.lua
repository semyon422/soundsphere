local Class				= require("Class")
local json				= require("json")
local ReplayNanoChart	= require("sphere.models.ReplayModel.ReplayNanoChart")
local ReplayConverter	= require("sphere.models.ReplayModel.ReplayConverter")
local InputMode			= require("ncdk.InputMode")

local Replay = Class:new()

Replay.construct = function(self)
	self.replayNanoChart = ReplayNanoChart:new()
	self.replayConverter = ReplayConverter:new()
	self.events = {}
	self.eventOffset = 0
end

Replay.receive = function(self, event)
	if not event.virtual then
		return
	end

	local events = self.events
	events[#events + 1] = {
		event[1],
		name = event.name,
		time = event.time - self.logicEngine.inputOffset,
	}
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

Replay.toString = function(self)
	local content, size = self.replayNanoChart:encode(self.events, self.inputMode)
	return json.encode({
		hash = self.noteChartDataEntry.hash,
		index = self.noteChartDataEntry.index,
		inputMode = tostring(self.inputMode),
		modifiers = self.modifierTable,
		player = "Player",
		time = os.time(),
		events = content,
		size = size,
		type = "NanoChart",
		timings = self.timings
	})
end

Replay.fromString = function(self, s)
	local object = json.decode(s)

	self.replayConverter:convert(object)

	self.hash = object.hash
	self.index = object.index
	self.modifiers = object.modifiers
	self.player = object.player
	self.time = object.time
	self.timings = object.timings

	if not object.inputMode then
		self.events = {}
		return self
	end

	local inputMode = InputMode:new(object.inputMode)
	self.events = self.replayNanoChart:decode(object.events, object.size, inputMode)

	return self
end

return Replay
