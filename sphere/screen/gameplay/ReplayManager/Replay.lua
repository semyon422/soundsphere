local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local json				= require("json")
local zlib				= require("zlib")
local mime				= require("mime")

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

Replay.toString = function(self)
	local jsonData = json.encode(self.events)
	local compressedEvents = zlib.compress(jsonData)
	local b64Events = mime.b64(compressedEvents)
	return json.encode({
		hash = self.noteChartDataEntry.hash,
		index = self.noteChartDataEntry.index,
		modifiers = self.modifierSequence:toTable(),
		events = b64Events,
		size = #jsonData
	})
end

Replay.fromString = function(self, s)
	local object = json.decode(s)

	self.hash = object.hash
	self.index = object.hash
	self.modifiers = object.modifiers

	self.events = json.decode(zlib.uncompress(mime.unb64(object.events), nil, object.size))

	return self
end

return Replay
