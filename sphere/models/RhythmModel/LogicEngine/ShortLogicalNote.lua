local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.noteClass = "ShortLogicalNote"

ShortLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex
	self.state = "clear"
end

ShortLogicalNote.update = function(self)
	if self.ended then
		return
	end

	if self.autoplay then
		return self:processAuto()
	end

	local timeState = self:getTimeState()
	self:processTimeState(timeState)

	if self.ended then
		local nextNote = self:getNextPlayable()
		if nextNote then
			return nextNote:update()
		end
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

ShortLogicalNote.switchState = function(self, newState)
	local oldState = self.state
	self.state = newState

	if self.autoplay then
		return
	end

	local config = self.logicEngine.timings.ShortScoreNote
	local currentTime = math.min(self.timeEngine.currentTime, self.startNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.hit, config.miss))
	if self.keyState then
		currentTime = self.eventTime
		print(currentTime, self.startNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.hit, config.miss))
		print(self.startNoteData.timePoint.absoluteTime, self:getLastTimeFromConfig(config.hit, config.miss))
		print(self:getTimeState())
		assert(currentTime <= self.startNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.hit, config.miss))
	end

	-- print("score", self:getEventTime())
	self:sendScore({
		name = "ScoreNoteState",
		noteType = "ShortScoreNote",
		currentTime = currentTime,
		-- currentTime = self:getEventTime(),
		noteTime = self.startNoteData.timePoint.absoluteTime,
		timeRate = self.scoreEngine.timeRate,
		notesCount = self.logicEngine.notesCount,
		oldState = oldState,
		newState = newState,
		minTime = self.scoreEngine.minTime,
		maxTime = self.scoreEngine.maxTime
	})
end

ShortLogicalNote.processAuto = function(self)
	local currentTime = self.timeEngine.currentTime
	-- local currentTime = self.logicEngine.exactCurrentTimeNoOffset or self.logicEngine.currentTime
	-- if self.logicEngine.autoplay then
	-- 	currentTime = self.logicEngine.currentTime
	-- end

	local deltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	if deltaTime >= 0 then
		self.keyState = true
		self:sendState("keyState")

		self.eventTime = self.startNoteData.timePoint.absoluteTime
		self:processTimeState("exactly")
		self.eventTime = nil
	end
end

ShortLogicalNote.getTimeState = function(self)
	local currentTime = self.timeEngine.currentTime
	if self.eventTime then
		currentTime = self.eventTime
	end
	-- local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self.startNoteData.timePoint.absoluteTime) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.ShortScoreNote
	return self:getTimeStateFromConfig(config.hit, config.miss, deltaTime)
end

ShortLogicalNote.isReachable = function(self)
	return self:getTimeState() ~= "too early"
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

	local key = event and event[1]
	if key == self.keyBind then
		self.eventTime = event.time
		self:update()
		if self.ended then
			local nextNote = self:getNextPlayable()
			if nextNote then
				return nextNote:receive(event)
			end
			return
		end
		if event.name == "keypressed" then
			self.keyState = true
		elseif event.name == "keyreleased" then
			self.keyState = false
		end
		self:sendState("keyState")
		self:update()
		self.eventTime = nil
	end
end

return ShortLogicalNote
