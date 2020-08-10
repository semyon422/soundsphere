local ImageFrame	= require("aqua.graphics.ImageFrame")
local image			= require("aqua.image")
local GraphicalNote = require("sphere.views.RhythmView.GraphicalNote")

local ImageNote = GraphicalNote:new()

ImageNote.construct = function(self)
	self.images = self.startNoteData.images
end

ImageNote.update = function(self)
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

ImageNote.activate = function(self)
	local drawable = self:getDrawable()
	if drawable then
		drawable:reload()
		self.drawable = drawable
		self.container = self:getContainer()
		self.container:add(drawable)
	end

	self.activated = true
end

ImageNote.deactivate = function(self)
	local drawable = self.drawable
	if drawable then
		self.container:remove(drawable)
	end
	self.activated = false
end

ImageNote.reload = function(self)
	local drawable = self.drawable
	if not drawable then
		return
	end
	drawable.sx = self:getScaleX()
	drawable.sy = self:getScaleY()
	drawable:reload()
end

ImageNote.computeVisualTime = function(self)
end

ImageNote.computeTimeState = function(self)
	self.timeState = self.timeState or {}
end

ImageNote.getContainer = function(self)
	return self.graphicEngine.container
end

ImageNote.getDrawable = function(self)
	local path = self.graphicEngine.localAliases[self.startNoteData.images[1][1]] or self.graphicEngine.globalAliases[self.startNoteData.images[1][1]]
	self.image = image.getImage(path)

	if not self.image then
		return
	end

	return ImageFrame:new({
		image = self.image,
		cs = self.noteSkinView:getCS(self),
		layer = self.noteSkinView:getNoteLayer(self, "Head"),
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

ImageNote.willDrawBeforeStart = function(self)
	local nextNote = self:getNext(1)

	if not nextNote then
		return false
	end

	return not nextNote:willDrawAfterEnd()
end

ImageNote.willDrawAfterEnd = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.absoluteTime

	if dt < 0 then
		return true
	end
end

ImageNote.getHeadWidth = function(self)
	return self.noteSkinView:getG(self, "Head", "w", self.timeState)
end

ImageNote.getHeadHeight = function(self)
	return self.noteSkinView:getG(self, "Head", "h", self.timeState)
end

ImageNote.getX = function(self)
	return self.noteSkinView:getG(self, "Head", "x", self.timeState)
end

ImageNote.getY = function(self)
	return self.noteSkinView:getG(self, "Head", "y", self.timeState)
end

ImageNote.getScaleX = function(self)
	local image = self.image
	if not image then
		return
	end
	return self:getHeadWidth() / self.noteSkinView:getCS(self):x(image:getWidth())
end

ImageNote.getScaleY = function(self)
	local image = self.image
	if not image then
		return
	end
	return self:getHeadHeight() / self.noteSkinView:getCS(self):y(image:getHeight())
end

ImageNote.getColor = function(self)
	return self.noteSkinView:getG(self, "Head", "color", self.timeState)
end

return ImageNote
