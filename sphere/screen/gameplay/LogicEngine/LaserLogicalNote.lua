local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")
local LongLogicalNote = require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")

local LaserLogicalNote = LogicalNote:new()

LaserLogicalNote.noteClass = "LaserLogicalNote"

LaserLogicalNote.construct = LongLogicalNote.construct

LaserLogicalNote.update = LongLogicalNote.update

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

	local nextNote = self:getNextPlayable()
	if not nextNote then
		return
	end
	if self:getLastState() == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LaserLogicalNote.processAuto = LongLogicalNote.processAuto

LaserLogicalNote.receive = LongLogicalNote.receive

return LaserLogicalNote
