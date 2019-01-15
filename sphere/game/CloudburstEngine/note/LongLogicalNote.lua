local AudioManager = require("aqua.audio.AudioManager")

local LogicalNote = require("sphere.game.CloudburstEngine.note.LogicalNote")

local LongLogicalNote = LogicalNote:new()

LongLogicalNote.process = function(self, startTimeState, endTimeState)
	if self.keyState and startTimeState == "none" then
		self.keyState = false
	elseif self.state == "clear" then
		if startTimeState == "late" then
			self.state = "startMissed"
		elseif self.keyState then
			if startTimeState == "early" then
				self.state = "startMissedPressed"
			elseif startTimeState == "exactly" then
				self.state = "startPassedPressed"
			end
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
