local Class = require("aqua.util.Class")

local GraphicalNote = Class:new()

GraphicalNote.init = function(self)
	self.inputId = self.startNoteData.inputType .. self.startNoteData.inputIndex
	self.id = self.inputId .. ":" .. self.noteType
		
	self.logicalNote = self.graphicEngine:getLogicalNote(self.startNoteData)
	-- self.logicalNote.graphicalNote = self
end

GraphicalNote.getCS = function(self)
	return self.graphicEngine.noteSkin:getCS(self)
end

GraphicalNote.getNext = function(self, offset)
	return self.noteDrawer.noteData[self.index + 1]
end

GraphicalNote.updateNext = function(self, offset)
	local nextNote = self.noteDrawer.noteData[self.index + offset]
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
