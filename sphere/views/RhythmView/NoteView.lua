local Class = require("Class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = Class:new()

NoteView.construct = function(self)
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
end

local noteParts = {}

NoteView.getNotePart = function(self, name)
	local part = noteParts[name]
	if not part then
		part = NotePartView:new({name = name})
		noteParts[name] = part
	end
	part.noteView = self
	return part
end

NoteView.getDraw = function(self, quad, ...)
	if quad then
		return quad, ...
	end
	return ...
end

NoteView.draw = function(self) end

NoteView.isVisible = function(self)
	return true
end

return NoteView
