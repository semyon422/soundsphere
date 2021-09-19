local Class = require("aqua.util.Class")

local NotePartView = Class:new()

NotePartView.timeState = {}

NotePartView.construct = function(self, noteView, name)
	self.noteView = noteView
	self.name = name
end

NotePartView.get = function(self, key, timeState)
	return self.noteView.noteSkin:get(self.noteView, self.name, key, timeState or self.timeState)
end

NotePartView.getSpriteBatch = function(self, key, timeState)
	return self.noteView.rhythmView:getSpriteBatch(self.noteView, self.name, key or "image", timeState or self.timeState)
end

NotePartView.getQuad = function(self, key, timeState)
	return self.noteView.rhythmView:getQuad(self.noteView, self.name, key or "image", timeState or self.timeState)
end

NotePartView.getDimensions = function(self, key, timeState)
	return self.noteView.rhythmView:getDimensions(self.noteView, self.name, key or "image", timeState or self.timeState)
end

return NotePartView
