local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local json				= require("json")
local ReplayNanoChart	= require("sphere.models.ReplayModel.ReplayNanoChart")
local InputMode			= require("ncdk.InputMode")

local Replay = Class:new()

Replay.construct = function(self)
	self.replayNanoChart = ReplayNanoChart:new()
	self.observable = Observable:new()
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
		time = event.time - self.timeEngine.inputOffset,
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
		inputMode = self.inputMode:getString(),
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

	self.hash = object.hash
	self.index = object.index
	self.modifiers = object.modifiers
	self.player = object.player
	self.time = object.time
	self.timings = object.timings
	if object.inputMode then
		self.inputMode = InputMode:new():setString(object.inputMode)
	end

	self.events = self.replayNanoChart:decode(object.events, object.size, self.inputMode)

	local timings = self.timings
	if timings and not timings.ShortNote then
		timings.ShortNote = timings.ShortScoreNote
		timings.LongNote = timings.LongScoreNote
		timings.ShortScoreNote = nil
		timings.LongScoreNote = nil
	end

	return self
end

return Replay
