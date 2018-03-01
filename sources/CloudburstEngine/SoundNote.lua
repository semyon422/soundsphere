CloudburstEngine.SoundNote = createClass(CloudburstEngine.LogicalNote)
local SoundNote = CloudburstEngine.SoundNote

SoundNote.update = function(self)
	if self.state == "passed" then
		return
	end
	
	if self.noteData.startTimePoint:getAbsoluteTime() <= self.engine.currentTime then
		if self.soundFilePath then
			audioManager:playSound(self.soundFilePath, "engine")
		end
		
		self.state = "passed"
		self:next()
	end
end