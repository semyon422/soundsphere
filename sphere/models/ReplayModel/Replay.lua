local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local json				= require("json")
local ReplayNanoChart	= require("sphere.models.ReplayModel.ReplayNanoChart")
local ReplayJson		= require("sphere.models.ReplayModel.ReplayJson")
local InputMode			= require("ncdk.InputMode")

local Replay = Class:new()

Replay.type = "NanoChart"

Replay.construct = function(self)
	self.replayNanoChart = ReplayNanoChart:new()
	self.replayJson = ReplayJson:new()
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
		time = event.time,
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
	local content, size
	if self.type == "NanoChart" then
		content, size = self.replayNanoChart:encode(self.events, self.inputMode)
	elseif self.type == "Json" then
		content, size = self.replayJson:encode(self.events)
	end
	return json.encode({
		hash = self.noteChartDataEntry.hash,
		index = self.noteChartDataEntry.index,
		inputMode = self.inputMode:getString(),
		modifiers = self.modifierTable,
		player = "Player",
		time = os.time(),
		events = content,
		size = size,
		type = self.type,
		timings = self.timings
	})
end

Replay.fromString = function(self, s)
	local object = json.decode(s)

	self.hash = object.hash
	self.index = object.hash
	self.modifiers = object.modifiers
	self.player = object.player
	self.time = object.time
	self.timings = object.timings
	if object.inputMode then
		self.inputMode = InputMode:new():setString(object.inputMode)
	end

	if object.type == "NanoChart" then
		self.events = self.replayNanoChart:decode(object.events, object.size, self.inputMode)
	elseif object.type == "Json" or not object.type then
		self.events = self.replayJson:decode(object.events, object.size)
	end

	return self
end

return Replay
