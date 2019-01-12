local Class = require("aqua.util.Class")

local Score = Class:new()

Score.load = function(self)
	self.combo = 0
end

Score.receive = function(self, event)
	if event.name == "logicalNoteUpdated" then
		local state = event.logicalNote.state
		if
			state == "passed" or
			state == "startPassedPressed"
		then
			if self.combo == 0 then
				print("starting new combo")
			end
			self.combo = self.combo + 1
		elseif (
			state == "missed" or
			state == "startMissed" or
			state == "startMissedPressed" or
			state == "startMissed" or
			state == "endMissed"
		) and self.combo ~= 0 then
			print("combo breaked: " .. self.combo)
			self.combo = 0
		end
	end
end

Score.unload = function(self)
	print("latest combo: " .. self.combo)
end

return Score
