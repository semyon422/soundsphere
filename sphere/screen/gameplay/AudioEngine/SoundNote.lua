local Class = require("aqua.util.Class")

local SoundNote = Class:new()

SoundNote.receive = function(self, event) end

SoundNote.playAudio = function(self, noteData, layer)
	return self.audioEngine:playAudio(noteData.sounds, layer, noteData.keysound, noteData.stream)
end

return SoundNote
