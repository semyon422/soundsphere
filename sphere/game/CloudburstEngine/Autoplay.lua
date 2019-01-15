local Autoplay = {}

Autoplay.processNote = function(self, note)
	if note.noteType == "ShortNote" then
		self:processShortNote(note)
	elseif note.noteType == "LongNote" then
		self:processLongNote(note)
	end
end

Autoplay.processShortNote = function(self, note)
	local deltaTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	if deltaTime < 0 then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:clickKey()
		end
		note.noteHandler:playAudio(note.pressSoundFilePath)
		
		note.keyState = true
		note.state = "passed"
		return note:next()
	end
end

Autoplay.processLongNote = function(self, note)
	local deltaStartTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	local deltaEndTime = note.endNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	
	if deltaStartTime < 0 and not note.keyState then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:switchKey(true)
		end
		note.noteHandler:playAudio(note.pressSoundFilePath)
		
		note.keyState = true
		note.state = "startPassedPressed"
	elseif deltaEndTime < 0 and note.keyState then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:switchKey(false)
		end
		note.noteHandler:playAudio(note.releaseSoundFilePath)
		
		deltaEndTime = 0
		endTimeState = "exactly"
		note.keyState = false
		note.state = "endPassed"
		return note:next()
	end
end

return Autoplay
