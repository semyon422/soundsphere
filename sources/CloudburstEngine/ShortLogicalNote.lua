CloudburstEngine.ShortLogicalNote = createClass(CloudburstEngine.LogicalNote)
local ShortLogicalNote = CloudburstEngine.ShortLogicalNote

ShortLogicalNote.update = function(self)
	if self.ended or self.state == "passed" then
		return
	end
	
	local deltaTime = self.startNoteData.timePoint:getAbsoluteTime() - self.engine.currentTime
	
	local timeState = self.engine:getTimeState(deltaTime)
	
	self.oldState = self.state
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.keyState and timeState == "early" then
		self.state = "missed"
		self:sendState()
		self:next()
	elseif timeState == "late" then
		self.state = "missed"
		self:sendState()
		self:next()
	elseif self.keyState and timeState == "exactly" then
		self.state = "passed"
		self:sendState()
		self:next()
	end
end