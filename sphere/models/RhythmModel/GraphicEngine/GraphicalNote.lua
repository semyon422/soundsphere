local class = require("class")

---@class sphere.GraphicalNote
---@operator call: sphere.GraphicalNote
local GraphicalNote = class()

---@param noteType string?
---@param noteData ncdk.NoteData?
function GraphicalNote:new(noteType, noteData)
	self.noteType = noteType
	self.startNoteData = noteData
end

function GraphicalNote:update() end

---@return string
function GraphicalNote:getLogicalState()
	local logicalNote = self.graphicEngine:getLogicalNote(self.startNoteData)
	return logicalNote and logicalNote.state or "clear"
end

---@return number?
function GraphicalNote:getPressedTime()
	local logicalNote = self.graphicEngine:getLogicalNote(self.startNoteData)
	return logicalNote and logicalNote.pressedTime
end

---@param timePoint ncdk.TimePoint
---@return number
function GraphicalNote:getVisualTime(timePoint)
	if self.graphicEngine.constant then
		return timePoint.absoluteTime
	end
	return timePoint:getVisualTime(self.currentTimePoint)
end

---@param time number
---@return number
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

---@return number
function GraphicalNote:whereWillDraw()
	return 0
end

---@return boolean
function GraphicalNote:willDraw()
	return self:whereWillDraw() == 0
end

---@return boolean
function GraphicalNote:willDrawBeforeStart()
	return self:whereWillDraw() == -1
end

---@return boolean
function GraphicalNote:willDrawAfterEnd()
	return self:whereWillDraw() == 1
end

return GraphicalNote
