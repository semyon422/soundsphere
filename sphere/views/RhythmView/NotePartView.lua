local Class = require("Class")

local NotePartView = Class:new()

NotePartView.timeState = {}

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

NotePartView.getColor = function(self)
	local noteSkin = self.noteView.noteSkin
	local color = noteSkin:get(self.noteView, self.name, "color", self.timeState)
	local imageName, frame = noteSkin:get(self.noteView, self.name, "image", self.timeState)
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
