CloudburstEngine.SoundNote = createClass(CloudburstEngine.LogicalNote)
local SoundNote = CloudburstEngine.SoundNote

SoundNote.update = function(self)
	if self.ended or self.state ~= "clear" then
		return
	end
	
	if
		not self.pressSoundFilePath or
		self.startNoteData.timePoint:getAbsoluteTime() <= self.engine.currentTime
	then
		if self.pressSoundFilePath then
			self.engine.core.audioManager:playSound(self.pressSoundFilePath)
		end
		self.state = "skipped"
		return self:next()
	end
end