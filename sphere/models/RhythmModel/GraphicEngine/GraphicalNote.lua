local Class = require("aqua.util.Class")

local GraphicalNote = Class:new()

GraphicalNote.init = function(self)
	self.logicalNote = self.graphicEngine:getLogicalNote(self.startNoteData)
end

GraphicalNote.getNext = function(self, offset)
	return self.noteDrawer.noteData[self.index + offset]
end

GraphicalNote.updateNext = function(self, offset)
	local nextNote = self:getNext(offset)
	if nextNote and nextNote.activated then
		return nextNote:update()
	end
end

GraphicalNote.tryNext = function(self)
	if self.index == self.noteDrawer.startNoteIndex and self:willDrawBeforeStart() then
		self:deactivate()
		self.noteDrawer.startNoteIndex = self.noteDrawer.startNoteIndex + 1
		self:updateNext(1)
		return true
	elseif self.index == self.noteDrawer.endNoteIndex and self:willDrawAfterEnd() then
		self:deactivate()
		self.noteDrawer.endNoteIndex = self.noteDrawer.endNoteIndex - 1
		self:updateNext(-1)
		return true
	end
end

GraphicalNote.receive = function(self, event) end

GraphicalNote.where = function(self, time)
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

GraphicalNote.sendState = function(self)
	return self.graphicEngine.observable:send({
		name = "GraphicalNoteState",
		note = self
	})
end

return GraphicalNote
