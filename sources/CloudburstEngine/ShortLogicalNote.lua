CloudburstEngine.ShortLogicalNote = createClass(CloudburstEngine.LogicalNote)
local ShortLogicalNote = CloudburstEngine.ShortLogicalNote

ShortLogicalNote.update = function(self)
	if self.state == "passed" then
		return
	end
	
	local deltaTime = self.noteData.startTimePoint:getAbsoluteTime() - self.engine.currentTime
	
	local timeState = self.engine:getTimeState(deltaTime)
	
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.keyState and timeState == "early" then
		self.state = "missed"
		self:next()
	elseif timeState == "late" then
		self.state = "missed"
		self:next()
	elseif self.keyState and timeState == "exactly" then
		self.state = "passed"
		self:next()
	end
end