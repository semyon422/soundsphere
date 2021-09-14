local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.noteClass = "ShortLogicalNote"

ShortLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex

	LogicalNote.construct(self)

	self:switchState("clear")
end

ShortLogicalNote.update = function(self)
	if self.ended then
		return
	end

	self.eventTime = self.eventTime or self.logicEngine.currentTime

	local timeState = self.scoreNote:getTimeState()

	local numStates = #self.states
	if not self.autoplay then
		self:processTimeState(timeState)
	else
		self:processAuto()
	end

	if numStates ~= #self.states then
		return self:update()
	else
		self.eventTime = nil
	end
end

ShortLogicalNote.processTimeState = function(self, timeState)
	local keyState = self.keyState
	if keyState and timeState == "too early" then
		self.keyState = false
	elseif keyState and (timeState == "early" or timeState == "late") or timeState == "too late" then
		self:switchState("missed")
		return self:next()
	elseif keyState and timeState == "exactly" then
		self:switchState("passed")
		return self:next()
	end
end

ShortLogicalNote.processAuto = function(self)
	local currentTime = self.logicEngine.exactCurrentTimeNoOffset
	if self.logicEngine.autoplay then
		currentTime = self.logicEngine.currentTime
	end

	local deltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	if deltaTime >= 0 then
		self.keyState = true
		self:sendState("keyState")

		self.eventTime = self.startNoteData.timePoint.absoluteTime
		self:processTimeState("exactly")
		self.eventTime = nil
	end
end

ShortLogicalNote.receive = function(self, event)
	if self.logicEngine.autoplay then
		return
	end

	if self.autoplay then
		local nextNote = self:getNextPlayable()
		if nextNote then
			return nextNote:receive(event)
		end
		return
	end

	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			self.keyState = true
			self:sendState("keyState")
			self.eventTime = event.time
		elseif event.name == "keyreleased" then
			self.keyState = false
			self:sendState("keyState")
			self.eventTime = event.time
		end
	end
end

return ShortLogicalNote
