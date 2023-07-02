local Class				= require("Class")
local json				= require("json")
local ReplayNanoChart	= require("sphere.models.ReplayModel.ReplayNanoChart")
local InputMode			= require("ncdk.InputMode")

local Replay = Class:new()

Replay.construct = function(self)
	self.replayNanoChart = ReplayNanoChart:new()
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

	local timings = self.timings
	if not timings then
		return self
	end

	if not timings.ShortNote then
		timings.ShortNote = timings.ShortScoreNote
		timings.LongNoteStart = {
			hit = timings.LongScoreNote.startHit,
			miss = timings.LongScoreNote.startMiss,
		}
		timings.LongNoteEnd = {
			hit = timings.LongScoreNote.endHit,
			miss = timings.LongScoreNote.endMiss,
		}
		timings.ShortScoreNote = nil
		timings.LongScoreNote = nil
	end
	if not timings.LongNoteStart then
		timings.LongNoteStart = {
			hit = timings.LongNote.startHit,
			miss = timings.LongNote.startMiss,
		}
		timings.LongNoteEnd = {
			hit = timings.LongNote.endHit,
			miss = timings.LongNote.endMiss,
		}
		timings.LongNote = nil
	end

	return self
end

return Replay
