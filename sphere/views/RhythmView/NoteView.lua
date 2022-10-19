local Class = require("Class")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local NoteView = Class:new()

NoteView.construct = function(self)
	self.startChord = {}
	self.endChord = {}
	self.middleChord = {}
end

NoteView.getNotePart = function(self, name)
	local part = self[name]
	if part then
		return part
	end
	self[name] = NotePartView:new({
		noteView = self,
		name = name,
	})
	return self[name]
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
