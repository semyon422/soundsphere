local Class = require("aqua.util.Class")

local NotePartView = Class:new()

NotePartView.noteView = {}
NotePartView.name = "Head"
NotePartView.timeState = {}

NotePartView.get = function(self, key)
	return self.noteView.noteSkin:get(self.noteView, self.name, key, self.timeState)
end

NotePartView.getSpriteBatch = function(self)
	return self.noteView.rhythmView:getSpriteBatch(self.noteView, self.name)
end

NotePartView.getQuad = function(self)
	return self.noteView.rhythmView:getQuad(self.noteView, self.name)
end

NotePartView.getWidth = function(self)
	return self.noteView.rhythmView:getNoteImageWidth(self.noteView, self.name)
end

NotePartView.getHeight = function(self)
	return self.noteView.rhythmView:getNoteImageHeight(self.noteView, self.name)
end

return NotePartView
