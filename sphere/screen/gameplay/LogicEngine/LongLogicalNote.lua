local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

local LongLogicalNote = LogicalNote:new()

LongLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	self.pressSounds = self.startNoteData.sounds
	self.releaseSounds = self.endNoteData.sounds

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex
end

LongLogicalNote.process = function(self)
	local deltaStartTime = self.logicEngine.currentTime - self.startNoteData.timePoint.absoluteTime
	local deltaEndTime = self.logicEngine.currentTime - self.endNoteData.timePoint.absoluteTime
	local startTimeState = self.score:getTimeState(deltaStartTime)
	local endTimeState = self.score:getTimeState(deltaEndTime)
	
	-- local oldState = note.state
	if not self.autoplay then
		self:processTimeState(startTimeState, endTimeState)
	else
		self:processAuto()
	end

	-- self:processLongNoteState(note.state, oldState)
	
	-- if note.started and not note.judged then
	-- 	self:hit(deltaStartTime, note.startNoteData.timePoint.absoluteTime)
	-- 	note.judged = true
	-- end
end

LongLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	if self.keyState and startTimeState == "none" then
		self.keyState = false
	elseif self.state == "clear" then
		if startTimeState == "late" then
			self.state = "startMissed"
			self.started = true
		elseif self.keyState then
			if startTimeState == "early" then
				self.state = "startMissedPressed"
			elseif startTimeState == "exactly" then
				self.state = "startPassedPressed"
			end
			self.started = true
		end
	elseif self.state == "startPassedPressed" then
		if not self.keyState then
			if endTimeState == "none" then
				self.state = "startMissed"
			elseif endTimeState == "exactly" then
				self.state = "endPassed"
				return self:next()
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			return self:next()
		end
	elseif self.state == "startMissedPressed" then
		if not self.keyState then
			if endTimeState == "exactly" then
				self.state = "endMissedPassed"
				return self:next()
			else
				self.state = "startMissed"
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			return self:next()
		end
	elseif self.state == "startMissed" then
		if self.keyState then
			self.state = "startMissedPressed"
		elseif endTimeState == "late" then
			self.state = "endMissed"
			return self:next()
		end
	end
	
	local nextNote = self:getNext()
	if nextNote and self.state == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LongLogicalNote.processAuto = function(self)
	local deltaStartTime = self.startNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	local deltaEndTime = self.endNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	
	local nextNote = self:getNext()
	if deltaStartTime <= 0 and not self.keyState then
		self.keyState = true
		self:sendState("keyState")
		
		self:processTimeState("exactly", "none")
		-- note.score:processLongNoteState("startPassedPressed", "clear")
		
		-- if note.started and not note.judged then
		-- 	note.score:hit(0, note.startNoteData.timePoint.absoluteTime)
		-- 	note.judged = true
		-- end
	elseif deltaEndTime <= 0 and self.keyState or nextNote and nextNote:isHere() then
		self.keyState = false
		self:sendState("keyState")
		
		self:processTimeState("none", "exactly")
		-- note.score:processLongNoteState("endPassed", "startPassedPressed")
	end
end

LongLogicalNote.receive = function(self, event)
	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			self.keyState = true
			return self:sendState("keyState")
		elseif event.name == "keyreleased" then
			self.keyState = false
			return self:sendState("keyState")
		end
	end
end

return LongLogicalNote
