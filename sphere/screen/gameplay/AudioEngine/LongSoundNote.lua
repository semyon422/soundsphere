local SoundNote = require("sphere.screen.gameplay.AudioEngine.SoundNote")

local LongSoundNote = SoundNote:new()

LongSoundNote.receive = function(self, event)
    if event.key == "keyState" then
		local note = event.note
		if note[event.key] then
			return self:playAudio(note.startNoteData, "foreground")
		else
			return self:playAudio(note.endNoteData, "foreground")
		end
	end
end

return LongSoundNote
