local SoundNote = require("sphere.screen.gameplay.AudioEngine.SoundNote")

local ShortSoundNote = SoundNote:new()

ShortSoundNote.receive = function(self, event)
    if event.key == "keyState" then
		local note = event.note
		if event.value then
			return self:playAudio(note.startNoteData, "foreground")
		end
	end
end

return ShortSoundNote
