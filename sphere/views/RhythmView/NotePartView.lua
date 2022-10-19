local Class = require("Class")

local NotePartView = Class:new()

NotePartView.getTimeState = function(self)
	local graphicalNote = self.noteView.graphicalNote
	return graphicalNote.startTimeState or graphicalNote.timeState
end

NotePartView.get = function(self, key, timeState)
	return self.noteView.noteSkin:get(self.noteView, self.name, key, timeState or self:getTimeState())
end

NotePartView.getSpriteBatch = function(self, key, timeState)
	return self.noteView.rhythmView:getSpriteBatch(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

NotePartView.getQuad = function(self, key, timeState)
	return self.noteView.rhythmView:getQuad(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

NotePartView.getDimensions = function(self, key, timeState)
	return self.noteView.rhythmView:getDimensions(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

NotePartView.getColor = function(self)
	local noteSkin = self.noteView.noteSkin
	local color = noteSkin:get(self.noteView, self.name, "color", self:getTimeState())
	local imageName, frame = noteSkin:get(self.noteView, self.name, "image", self:getTimeState())
	local image = noteSkin.images[imageName]
	if not image then
		return color
	end
	if not image.color then
		return color
	end
	return noteSkin:multiplyColors(color, image.color)
end

return NotePartView
