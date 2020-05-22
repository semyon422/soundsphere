local Class = require("aqua.util.Class")

local LogicalNote = Class:new()

LogicalNote.construct = function(self)
	self:clearStates()
end

LogicalNote.switchState = function(self, name, time)
	local states = self.states
	states[#states + 1] = {
		name = name,
		time = time
	}
end

LogicalNote.getLastState = function(self)
	local states = self.states
	local state = states[#states]
	return state.name, state.time
end

LogicalNote.clearStates = function(self)
	self.states = {}
end

LogicalNote.switchAutoplay = function(self, value)
	self.autoplay = value
	self:clearStates()
	self:switchState("clear")
end

LogicalNote.getNext = function(self)
	return self.noteHandler.noteData[self.index + 1]
end

LogicalNote.getNextPlayable = function(self)
	local nextNote = self:getNext()
	while nextNote and nextNote.startNoteData.noteType == "SoundNote" do
		nextNote = nextNote:getNext()
	end
	return nextNote
end

LogicalNote.next = function(self)
	self.ended = true
end

LogicalNote.isHere = function(self)
	return self.scoreNote:isHere()
end

LogicalNote.isReachable = function(self)
	return self.scoreNote:isReachable()
end

LogicalNote.load = function(self)
	self.scoreNote:load()
	self:sendState("load")
end

LogicalNote.unload = function(self)
	self:sendState("unload")
end

LogicalNote.update = function(self) end

LogicalNote.receive = function(self, event) end

LogicalNote.sendState = function(self, key)
	return self.logicEngine:send({
		name = "LogicalNoteState",
		note = self,
		key = key,
		value = self[key]
	})
end

return LogicalNote
