local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
	
	self.pressSounds = self.startNoteData.sounds
end

ShortLogicalNote.process = function(self)
	local deltaTime = self.logicEngine.currentTime - self.startNoteData.timePoint.absoluteTime
	local timeState = self.score:getTimeState(deltaTime)
	
	self:processTimeState(timeState)
	-- self:processShortNoteState(note.state)
	
	-- if note.ended then
	-- 	self:hit(deltaTime, note.startNoteData.timePoint.absoluteTime)
	-- end
end

ShortLogicalNote.processTimeState = function(self, timeState)
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.keyState and timeState == "early" then
		self.state = "missed"
		return self:next()
	elseif timeState == "late" then
		self.state = "missed"
		return self:next()
	elseif self.keyState and timeState == "exactly" then
		self.state = "passed"
		return self:next()
	end
end

ShortLogicalNote.receive = function(self, event)
	local key = event.args and event.args[1]
	if key == self.noteHandler.keyBind then
		if event.name == "keypressed" then
			self.keyState = true
			return self.noteHandler:send({
				name = "KeyState",
				state = true,
				note = self,
				layer = "foreground"
			})
		elseif event.name == "keyreleased" then
			self.keyState = false
			return self.noteHandler:send({
				name = "KeyState",
				state = false,
				note = self,
				layer = "foreground"
			})
		end
	end
end

return ShortLogicalNote
