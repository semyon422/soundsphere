local Class = require("Class")

local GraphicalNote = Class:new()

GraphicalNote.update = function(self) end

GraphicalNote.getLogicalState = function(self)
	local logicalNote = self.logicalNote
	return logicalNote and logicalNote.state or "clear"
end

GraphicalNote.getPressedTime = function(self)
	local logicalNote = self.logicalNote
	return logicalNote and logicalNote.pressedTime
end

GraphicalNote.where = function(self, time)
	local rate = self.graphicEngine:getVisualTimeRate()
	time = time * rate / math.abs(rate)
	local range = self.graphicEngine.range
	if -time > range[2] then
		return 1
	elseif -time < range[1] then
		return -1
	else
		return 0
	end
end

GraphicalNote.whereWillDraw = function(self)
	return 0
end

GraphicalNote.willDraw = function(self)
	return self:whereWillDraw() == 0
end

GraphicalNote.willDrawBeforeStart = function(self)
	return self:whereWillDraw() == -1
end

GraphicalNote.willDrawAfterEnd = function(self)
	return self:whereWillDraw() == 1
end

return GraphicalNote
