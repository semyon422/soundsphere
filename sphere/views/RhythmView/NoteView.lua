local Class = require("aqua.util.Class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = Class:new()

NoteView.construct = function(self)
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
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

NoteView.updateChord = function(self, noteViews)
	local startChord = self.startChord
	local endChord = self.endChord
	local middleChord = self.middleChord
	for i = 1, self.noteSkin.inputsCount do
		startChord[i] = false
		endChord[i] = false
		middleChord[i] = false
	end

	local timePoint = self.startNoteData.timePoint
	local endTimePoint = self.endNoteData and self.endNoteData.timePoint
	local inputs = self.noteSkin.inputs
	for _, noteView in ipairs(noteViews) do
		local nd = noteView.startNoteData
		local endNd = noteView.endNoteData
		local column = inputs[nd.inputType .. nd.inputIndex]
		if column then
			if timePoint == nd.timePoint or (endNd and timePoint == endNd.timePoint) then
				startChord[column] = true
			end
			if endTimePoint == nd.timePoint or (endNd and endTimePoint == endNd.timePoint) then
				endChord[column] = true
			end
			if startChord[column] and endChord[column] then
				middleChord[column] = true
			end
		end
	end
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
