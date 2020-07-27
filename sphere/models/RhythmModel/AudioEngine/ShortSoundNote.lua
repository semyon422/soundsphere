local SoundNote = require("sphere.models.RhythmModel.AudioEngine.SoundNote")

local ShortSoundNote = SoundNote:new()

ShortSoundNote.receive = function(self, event)
    if event.key == "keyState" then
		local note = event.note
		if event.value then
			return self:playAudio(note.startNoteData)
		end
	end
end

return ShortSoundNote
