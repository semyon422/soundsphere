local Class = require("aqua.util.Class")

local NoteView = Class:new()

NoteView.getCS = function(self)
	return self.noteSkin:getCS(self)
end

NoteView.getNext = function(self, offset)
	return self.noteDrawer.noteData[self.index + offset]
end

NoteView.updateNext = function(self, offset)
	local nextNote = self:getNext(offset)
	if nextNote and nextNote.activated then
		return nextNote:update()
	end
end

NoteView.tryNext = function(self)
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

NoteView.getDraw = function(self, quad, ...)
	if quad then
		return quad, ...
	end
	return ...
end

NoteView.draw = function(self) end

NoteView.update = function(self) end

NoteView.receive = function(self, event) end

NoteView.whereWillDraw = function(self)
	return 0
end

NoteView.willDraw = function(self)
	return self:whereWillDraw() == 0
end

NoteView.willDrawBeforeStart = function(self)
	return self:whereWillDraw() == -1
end

NoteView.willDrawAfterEnd = function(self)
	return self:whereWillDraw() == 1
end

return NoteView
