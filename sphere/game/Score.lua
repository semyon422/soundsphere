local Class = require("aqua.util.Class")

local Score = Class:new()

Score.load = function(self)
	self.combo = 0
	self.maxcombo = 0
end

Score.receive = function(self, event)
	if event.name == "logicalNoteUpdated" then
		local state = event.logicalNote.state
		if
			state == "passed" or
			state == "startPassedPressed"
		then
			self.combo = self.combo + 1
			if self.combo > self.maxcombo then
				self.maxcombo = self.combo
			end
		elseif (
			state == "missed" or
			state == "startMissed" or
			state == "startMissedPressed" or
			state == "startMissed" or
			state == "endMissed"
		) and self.combo ~= 0 then
			self.combo = 0
		end
	end
end

Score.unload = function(self) end

return Score
