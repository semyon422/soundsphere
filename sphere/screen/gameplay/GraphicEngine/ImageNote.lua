local ImageFrame	= require("aqua.graphics.ImageFrame")
local image			= require("aqua.image")
local GraphicalNote = require("sphere.screen.gameplay.GraphicEngine.GraphicalNote")

local ImageNote = GraphicalNote:new()

ImageNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
	
	self.images = self.startNoteData.images
end

ImageNote.update = function(self)
	if not self:tryNext() then
		self.drawable.x = self:getX()
		self.drawable.y = self:getY()
		self.drawable.sx = self:getScaleX()
		self.drawable.sy = self:getScaleY()
		self.drawable:reload()
		self.drawable.color = {255, 255, 255}
	end
end

ImageNote.activate = function(self)
	self.drawable = self:getDrawable()
	self.drawable:reload()
	self.container = self:getContainer()
	self.container:add(self.drawable)
	
	self.activated = true
end

ImageNote.deactivate = function(self)
	self.container:remove(self.drawable)
	self.activated = false
end

ImageNote.reload = function(self)
	self.drawable.sx = self:getScaleX()
	self.drawable.sy = self:getScaleY()
	self.drawable:reload()
end

ImageNote.computeVisualTime = function(self)
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
		cs = self.noteSkin:getCS(self),
		layer = self.noteSkin:getNoteLayer(self, "Head"),
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
	return self.noteSkin:getG(0, 0, self, "Head", "w")
end

ImageNote.getHeadHeight = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "h")
end

ImageNote.getX = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "x")
end

ImageNote.getY = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "y")
end

ImageNote.getScaleX = function(self)
	return
		self:getHeadWidth() /
		self.noteSkin:getCS(self):x(self.image:getWidth())
end

ImageNote.getScaleY = function(self)
	return
		self:getHeadHeight() /
		self.noteSkin:getCS(self):y(self.image:getHeight())
end

return ImageNote
