local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

local LaserLogicalNote = LogicalNote:new()

LaserLogicalNote.noteClass = "LaserLogicalNote"

LaserLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex

	LogicalNote.construct(self)

	self:switchState("clear")
end

LaserLogicalNote.update = function(self)
	if self.ended then
		return
	end

	local startTimeState = self.scoreNote:getStartTimeState()
	local endTimeState = self.scoreNote:getEndTimeState()

	local numStates = #self.states
	if not self.autoplay then
		self:processTimeState(startTimeState, endTimeState)
	else
		self:processAuto()
	end

	if numStates ~= #self.states then
		return self:update()
	end
end

LaserLogicalNote.next = function(self)
	local nextNote = self:getNext()
	if nextNote then
		nextNote.keyState = self.keyState
	end
	return LogicalNote.next(self)
end

LaserLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	local lastState = self:getLastState()

	if self.keyState and startTimeState == "none" then
	elseif lastState == "clear" then
		if startTimeState == "late" then
			self:switchState("startMissed")
			self.started = true
		elseif self.keyState then
			if startTimeState == "early" then
				-- self:switchState("startMissedPressed")
			elseif startTimeState == "exactly" then
				self:switchState("startPassedPressed")
				self.started = true
			end
		end
	elseif lastState == "startPassedPressed" then
		if not self.keyState then
			if endTimeState == "none" then
				self:switchState("startMissed")
			elseif endTimeState == "exactly" then
				self:switchState("endPassed")
				return self:next()
			end
		elseif endTimeState == "late" then
			-- self:switchState("endMissed")
			return self:next()
		end
	elseif lastState == "startMissedPressed" then
		if not self.keyState then
			if endTimeState == "exactly" then
				self:switchState("endMissedPassed")
				return self:next()
			else
				self:switchState("startMissed")
			end
		elseif endTimeState == "late" then
			-- self:switchState("endMissed")
			return self:next()
		end
	elseif lastState == "startMissed" then
		if self.keyState then
			self:switchState("startMissedPressed")
		elseif endTimeState == "late" then
			-- self:switchState("endMissed")
			return self:next()
		end
	end
	
	local nextNote = self:getNext()
	if nextNote and self:getLastState() == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LaserLogicalNote.processAuto = function(self)
	local deltaStartTime = self.startNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	local deltaEndTime = self.endNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	
	local nextNote = self:getNext()
	if deltaStartTime <= 0 and not self.keyState then
		self.keyState = true
		self:sendState("keyState")
		
		self.autoplayStart = true
		self:processTimeState("exactly", "none")
		-- note.score:processLongNoteState("startPassedPressed", "clear")
		
		-- if note.started and not note.judged then
		-- 	note.score:hit(0, note.startNoteData.timePoint.absoluteTime)
		-- 	note.judged = true
		-- end
	elseif deltaEndTime <= 0 and self.keyState or nextNote and nextNote:isHere() then
		self.keyState = false
		self:sendState("keyState")
		
		self.autoplayEnd = true
		self:processTimeState("none", "exactly")
		-- note.score:processLongNoteState("endPassed", "startPassedPressed")
	end
end

LaserLogicalNote.receive = function(self, event)
	if self.autoplay then
		return
	end

	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			self.keyState = true

			self.eventTime = event.time
			self:update()
			self.scoreNote:update()
			self.eventTime = nil

			return self:sendState("keyState")
		elseif event.name == "keyreleased" then
			self.keyState = false

			self.eventTime = event.time
			self:update()
			self.scoreNote:update()
			self.eventTime = nil

			return self:sendState("keyState")
		end
	end
end

return LaserLogicalNote
