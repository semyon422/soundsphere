local class = require("class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = class()

function NoteView:new(noteType)
	self.noteType = noteType
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
end

local noteParts = {}

function NoteView:getNotePart(name)
	local part = noteParts[name]
	if not part then
		part = NotePartView({name = name})
		noteParts[name] = part
	end
	part.noteView = self
	return part
end

function NoteView:getDraw(quad, ...)
	if quad then
		return quad, ...
	end
	return ...
end

function NoteView:draw() end

function NoteView:isVisible()
	return true
end

return NoteView
