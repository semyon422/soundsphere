local class = require("class")

local NotePartView = class()

function NotePartView:getTimeState()
	return self.noteView.graphicalNote.startTimeState
end

function NotePartView:get(key, timeState)
	local noteSkin = self.noteView.noteSkin
	return noteSkin:get(self.noteView, self.name, key, timeState or self:getTimeState())
end

function NotePartView:getSpriteBatch(key, timeState)
	return self.noteView.noteSkin.data:getSpriteBatch(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

function NotePartView:getQuad(key, timeState)
	return self.noteView.noteSkin.data:getQuad(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

function NotePartView:getDimensions(key, timeState)
	return self.noteView.noteSkin.data:getDimensions(self.noteView, self.name, key or "image", timeState or self:getTimeState())
end

function NotePartView:getColor()
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
