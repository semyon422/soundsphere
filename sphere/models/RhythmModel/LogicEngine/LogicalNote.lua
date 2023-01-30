local Class = require("Class")

local LogicalNote = Class:new()

LogicalNote.state = ""

LogicalNote.getTimeState = function(self)
	return "none"
end

LogicalNote.getLastTimeFromConfig = function(self, config)
	return math.max(config.hit[2], config.miss[2])
end

LogicalNote.getFirstTimeFromConfig = function(self, config)
	return math.min(config.hit[1], config.miss[1])
end

LogicalNote.getTimeStateFromConfig = function(self, config, deltaTime)
	local hit, miss = config.hit, config.miss
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

LogicalNote.getNext = function(self)
	return self.noteHandler.notes[self.index + 1]
end

LogicalNote.getNextPlayable = function(self)
	if self.nextPlayable then
		return self.nextPlayable
	end

	local nextNote = self:getNext()
	while nextNote and not nextNote.isPlayable do
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
	if self.isPlayable then
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

LogicalNote.update = function(self) end

return LogicalNote
