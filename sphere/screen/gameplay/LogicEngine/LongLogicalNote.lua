local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

local LongLogicalNote = LogicalNote:new()

LongLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	self.pressSounds = self.startNoteData.sounds
	self.releaseSounds = self.endNoteData.sounds
end

LongLogicalNote.process = function(self, startTimeState, endTimeState)
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
end

return LongLogicalNote
