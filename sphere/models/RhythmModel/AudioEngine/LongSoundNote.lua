local SoundNote = require("sphere.models.RhythmModel.AudioEngine.SoundNote")

local LongSoundNote = SoundNote:new()

LongSoundNote.receive = function(self, event)
    if event.key == "keyState" then
		local note = event.note
		if event.value then
			return self:playAudio(note.startNoteData)
		else
			return self:playAudio(note.endNoteData)
		end
	end
end

return LongSoundNote
