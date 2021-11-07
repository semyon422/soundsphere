local Class = require("aqua.util.Class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = Class:new()

NoteView.construct = function(self)
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
	self.middleChordFixed = false
end

NoteView.newNotePartView = function(self, part)
	return NotePartView:new({}, self, part)
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

NoteView.updateMiddleChord = function(self)
	if self.middleChordFixed then
		return
	end

	local startChord = self.startChord
	local endChord = self.endChord
	local middleChord = self.middleChord
	for i = 1, self.noteSkin.inputsCount do
		middleChord[i] = nil
		if startChord[i] == 1 and endChord[i] == 0 then
			middleChord[i] = 1
		end
	end
	self.middleChordFixed = true
end

NoteView.draw = function(self) end

NoteView.update = function(self) end

NoteView.receive = function(self, event) end

NoteView.isVisible = function(self)
	return true
end

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
