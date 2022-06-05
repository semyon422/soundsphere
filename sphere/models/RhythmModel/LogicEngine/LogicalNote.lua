local Class = require("aqua.util.Class")

local LogicalNote = Class:new()

LogicalNote.state = ""

LogicalNote.getTimeState = function(self)
	return "none"
end

LogicalNote.getLastTimeFromConfig = function(self, hit, miss)
	return math.max(hit[2], miss[2])
end

LogicalNote.getFirstTimeFromConfig = function(self, hit, miss)
	return math.min(hit[1], miss[1])
end

LogicalNote.getTimeStateFromConfig = function(self, hit, miss, deltaTime)
	if deltaTime >= hit[1] and deltaTime <= hit[2] then
		return "exactly"
	elseif deltaTime >= miss[1] and deltaTime < hit[1] then
		return "early"
	elseif deltaTime > hit[2] and deltaTime <= miss[2] then
		return "late"
	elseif deltaTime < miss[1] then
		return "too early"
	elseif deltaTime > miss[2] then
		return "too late"
	end
end

LogicalNote.switchState = function(self, name)
	self.state = name
end

LogicalNote.sendScore = function(self, event)
	self.scoreEngine.scoreSystem:receive(event)
end

LogicalNote.switchAutoplay = function(self, value)
	self.autoplay = value
end

LogicalNote.getNext = function(self)
	return self.noteHandler.noteData[self.index + 1]
end

LogicalNote.getNextPlayable = function(self)
	if self.nextPlayable then
		return self.nextPlayable
	end

	local nextNote = self:getNext()
	while nextNote and nextNote.startNoteData.noteType == "SoundNote" do
		nextNote = nextNote:getNext()
	end

	if nextNote then
		self.nextPlayable = nextNote
	end

	return nextNote
end

LogicalNote.next = function(self)
	self.ended = true
end

LogicalNote.getNoteTime = function(self)
	local offset = 0
	if self.playable then
		offset = self.timeEngine.inputOffset
	end
	return self.startNoteData.timePoint.absoluteTime + offset
end

LogicalNote.isHere = function(self)
	return self:getNoteTime() <= self.timeEngine.currentTime
	-- return self.startNoteData.timePoint.absoluteTime <= self:getEventTime()
end

LogicalNote.isReachable = function(self)
	return true
end

LogicalNote.getEventTime = function(self)
	return self.eventTime or self.logicEngine:getEventTime()
end

LogicalNote.load = function(self)
	self:sendState("load")
end

LogicalNote.unload = function(self)
	self:sendState("unload")
end

LogicalNote.update = function(self) end

LogicalNote.receive = function(self, event) end

local event = {name = "LogicalNoteState"}
LogicalNote.sendState = function(self, key)
	event.note = self
	event.key = key
	event.value = self[key]
	return self.logicEngine:send(event)
end

return LogicalNote
