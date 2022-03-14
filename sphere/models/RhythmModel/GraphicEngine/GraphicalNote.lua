local Class = require("aqua.util.Class")

local GraphicalNote = Class:new()

GraphicalNote.init = function(self)
	self.logicalNote = self.graphicEngine:getLogicalNote(self.startNoteData)
end

GraphicalNote.update = function(self)
	self:computeVisualTime()
	self:computeTimeState()

	return self:tryNext()
end

GraphicalNote.computeVisualTime = function(self) end

GraphicalNote.computeTimeState = function(self) end

GraphicalNote.getNext = function(self, offset)
	return self.noteDrawer.noteData[self.index + offset]
end

GraphicalNote.tryNext = function(self)
	if self.index == self.noteDrawer.startNoteIndex and self:willDrawBeforeStart() then
		self:deactivate()
		self.noteDrawer.startNoteIndex = self.noteDrawer.startNoteIndex + 1
	elseif self.index == self.noteDrawer.endNoteIndex and self:willDrawAfterEnd() then
		self:deactivate()
		self.noteDrawer.endNoteIndex = self.noteDrawer.endNoteIndex - 1
	end
end

GraphicalNote.where = function(self, time)
	local rate = self.graphicEngine:getVisualTimeRate()
	time = time * rate / math.abs(rate)
	local range = self.noteSkin.range
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

GraphicalNote.activate = function(self)
	self.activated = true
	self:sendState()
end

GraphicalNote.deactivate = function(self)
	self.activated = false
	self:sendState()
end

local event = {name = "GraphicalNoteState"}
GraphicalNote.sendState = function(self)
	event.note = self
	return self.graphicEngine.observable:send(event)
end

return GraphicalNote
