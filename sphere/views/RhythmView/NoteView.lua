local Class = require("Class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = Class:new()

NoteView.construct = function(self)
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
	self.middleChordFixed = false
end

NoteView.newNotePartView = function(self, part)
	return NotePartView:new({
		noteView = self,
		name = part,
	})
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
		if startChord[i] == "LongNoteStart" and endChord[i] == "LongNoteEnd" then
			middleChord[i] = startChord[i]
		end
	end
	self.middleChordFixed = true
end

NoteView.draw = function(self) end

NoteView.update = function(self) end

NoteView.isVisible = function(self)
	return true
end

return NoteView
