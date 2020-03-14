local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
	
	self.pressSounds = self.startNoteData.sounds
end

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
