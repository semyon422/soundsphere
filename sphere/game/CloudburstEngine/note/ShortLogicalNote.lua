local AudioManager = require("aqua.audio.AudioManager")

local LogicalNote = require("sphere.game.CloudburstEngine.note.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.process = function(self, timeState)
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.keyState and timeState == "early" then
		self.state = "missed"
		return self:next()
	elseif timeState == "late" then
		self.state = "missed"
		return self:next()
	elseif self.keyState and timeState == "exactly" then
		self.state = "passed"
		return self:next()
	end
end

return ShortLogicalNote
