local class = require("class")
local json = require("json")
local ReplayNanoChart = require("sphere.models.ReplayModel.ReplayNanoChart")
local ReplayConverter = require("sphere.models.ReplayModel.ReplayConverter")
local InputMode = require("ncdk.InputMode")

local Replay = class()

function Replay:new()
	self.replayNanoChart = ReplayNanoChart()
	self.replayConverter = ReplayConverter()
	self.events = {}
	self.eventOffset = 0
end

function Replay:receive(event)
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

function Replay:reset()
	self.eventOffset = 0
end

function Replay:step()
	self.eventOffset = math.min(self.eventOffset + 1, #self.events)
end

function Replay:getNextEvent()
	return self.events[self.eventOffset + 1]
end

function Replay:toString()
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

function Replay:fromString(s)
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

	local inputMode = InputMode(object.inputMode)
	self.events = self.replayNanoChart:decode(object.events, object.size, inputMode)

	return self
end

return Replay
