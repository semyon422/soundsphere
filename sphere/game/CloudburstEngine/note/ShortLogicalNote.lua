local AudioManager = require("aqua.audio.AudioManager")

local LogicalNote = require("sphere.game.CloudburstEngine.note.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.update = function(self)
	if self.ended or self.state == "passed" then
		return
	end
	
	local deltaTime = self.startNoteData.timePoint:getAbsoluteTime() - self.engine.currentTime
	if self.engine.autoplay and deltaTime < 0 then
		self.noteHandler:clickKey()
		
		if self.pressSoundFilePath then
			AudioManager:getAudio(self.pressSoundFilePath):play()
		end
		deltaTime = 0
		self.keyState = true
		self.state = "passed"
		self:sendState()
		return self:next()
	end
	
	local timeState = self.engine:getTimeState(deltaTime)
	
	self.oldState = self.state
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.keyState and timeState == "early" then
		self.state = "missed"
		self:sendState()
		return self:next()
	elseif timeState == "late" then
		self.state = "missed"
		self:sendState()
		return self:next()
	elseif self.keyState and timeState == "exactly" then
		self.state = "passed"
		self:sendState()
		return self:next()
	end
end

return ShortLogicalNote
