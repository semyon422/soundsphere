local ImageFrame	= require("aqua.graphics.ImageFrame")
local image			= require("aqua.image")
local NoteView = require("sphere.views.RhythmView.NoteView")

local ImageNoteView = NoteView:new()

ImageNoteView.construct = function(self)
	self.images = self.startNoteData.images
end

ImageNoteView.update = function(self)
	local drawable = self.drawable
	if not drawable then
		return
	end

	drawable.x = self:getX()
	drawable.y = self:getY()
	drawable.sx = self:getScaleX()
	drawable.sy = self:getScaleY()
	drawable:reload()
	drawable.color = self:getColor()
end

ImageNoteView.activate = function(self)
	local drawable = self:getDrawable()
	if drawable then
		drawable:reload()
		self.drawable = drawable
		self.container = self:getContainer()
		self.container:add(drawable)
	end
end

ImageNoteView.deactivate = function(self)
	local drawable = self.drawable
	if drawable then
		self.container:remove(drawable)
	end
end

ImageNoteView.reload = function(self)
	local drawable = self.drawable
	if not drawable then
		return
	end
	drawable.sx = self:getScaleX()
	drawable.sy = self:getScaleY()
	drawable:reload()
end

ImageNoteView.getContainer = function(self)
	return self.container
end

ImageNoteView.getDrawable = function(self)
	local path = self.graphicEngine.localAliases[self.startNoteData.images[1][1]] or self.graphicEngine.globalAliases[self.startNoteData.images[1][1]]
	self.image = image.getImage(path)

	if not self.image then
		return
	end

	return ImageFrame:new({
		image = self.image,
		cs = self.noteSkinImageView:getCS(self),
		layer = self.noteSkinImageView:getNoteLayer(self, "Head"),
		x = 0,
		y = 0,
		h = 1,
		w = 1,
		locate = "out",
		align = {
			x = "center",
			y = "center"
		}
	})
end

ImageNoteView.getHeadWidth = function(self)
	return self.noteSkinImageView:getG(self, "Head", "w", self.timeState)
end

ImageNoteView.getHeadHeight = function(self)
	return self.noteSkinImageView:getG(self, "Head", "h", self.timeState)
end

ImageNoteView.getX = function(self)
	return self.noteSkinImageView:getG(self, "Head", "x", self.timeState)
end

ImageNoteView.getY = function(self)
	return self.noteSkinImageView:getG(self, "Head", "y", self.timeState)
end

ImageNoteView.getScaleX = function(self)
	local image = self.image
	if not image then
		return
	end
	return self:getHeadWidth() / self.noteSkinImageView:getCS(self):x(image:getWidth())
end

ImageNoteView.getScaleY = function(self)
	local image = self.image
	if not image then
		return
	end
	return self:getHeadHeight() / self.noteSkinImageView:getCS(self):y(image:getHeight())
end

ImageNoteView.getColor = function(self)
	return self.noteSkinImageView:getG(self, "Head", "color", self.timeState)
end

return ImageNoteView
