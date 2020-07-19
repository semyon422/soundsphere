local Class = require("aqua.util.Class")

local SoundNote = Class:new()

SoundNote.receive = function(self, event) end

SoundNote.getLayer = function(self)
	return self.logicalNote.autoplay and "background" or "foreground"
end

SoundNote.playAudio = function(self, noteData)
	return self.audioEngine:playAudio(noteData.sounds, self:getLayer(), noteData.keysound, noteData.stream, noteData.timePoint.absoluteTime)
end

return SoundNote
