CloudburstEngine.SoundNote = createClass(CloudburstEngine.LogicalNote)
local SoundNote = CloudburstEngine.SoundNote

SoundNote.update = function(self)
	if self.state == "passed" then
		return
	end
	
	if self.startNoteData.timePoint:getAbsoluteTime() <= self.engine.currentTime then
		if self.pressSoundFilePath then
			audioManager:playSound(self.pressSoundFilePath, "engine")
		end
		
		self.state = "passed"
		self:next()
	end
end