local class = require("class")

local GraphicalNote = class()

function GraphicalNote:new(noteType, noteData)
	self.noteType = noteType
	self.startNoteData = noteData
end

function GraphicalNote:update() end

function GraphicalNote:getLogicalState()
	local logicalNote = self.logicalNote
	return logicalNote and logicalNote.state or "clear"
end

function GraphicalNote:getPressedTime()
	local logicalNote = self.logicalNote
	return logicalNote and logicalNote.pressedTime
end

function GraphicalNote:where(time)
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

function GraphicalNote:whereWillDraw()
	return 0
end

function GraphicalNote:willDraw()
	return self:whereWillDraw() == 0
end

function GraphicalNote:willDrawBeforeStart()
	return self:whereWillDraw() == -1
end

function GraphicalNote:willDrawAfterEnd()
	return self:whereWillDraw() == 1
end

return GraphicalNote
