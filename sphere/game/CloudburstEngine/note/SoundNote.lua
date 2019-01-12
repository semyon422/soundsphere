local AudioManager = require("aqua.audio.AudioManager")

local LogicalNote = require("sphere.game.CloudburstEngine.note.LogicalNote")

local SoundNote = LogicalNote:new()

SoundNote.update = function(self)
	if self.ended or self.state ~= "clear" then
		return
	end
	
	if
		not self.pressSoundFilePath or
		self.startNoteData.timePoint:getAbsoluteTime() <= self.engine.currentTime
	then
		if self.pressSoundFilePath then
			AudioManager:getAudio(self.pressSoundFilePath):play()
		end
		self.state = "skipped"
		return self:next()
	end
end

return SoundNote
