local Class = require("aqua.util.Class")
local ImageFrame = require("aqua.graphics.ImageFrame")
local image = require("aqua.image")

local ImageNote = Class:new()

ImageNote.getNext = function(self)
	return self.noteHandler.noteData[self.index + 1]
end

ImageNote.next = function(self)
	self.ended = true
	local nextNote = self:getNext()
	if nextNote then
		self.noteHandler.currentNote = nextNote
		nextNote:load()
		return nextNote:update()
	end
end

ImageNote.isHere = function(self)
	return self.noteData.timePoint.absoluteTime <= self.engine.currentTime
end

ImageNote.update = function(self)
	local nextNote = self:getNext()
	if nextNote and nextNote:isHere() then
		return self:next()
	end
end

ImageNote.setRate = function(self) end
ImageNote.pause = function(self) end
ImageNote.play = function(self) end

ImageNote.load = function(self)
	local path = self.engine.aliases[self.images[1][1]]
	self.image = image.getImage(path)
	
	if self.image then
		self.drawable = ImageFrame:new({
			image = self.image,
			cs = self.bga.cs,
			x = 0,
			y = 0,
			h = 1,
			w = 1,
			locate = "out",
			align = {
				x = "center",
				y = "center"
			},
			color = self.bga.color
		})
		self.drawable:reload()
	end
end

ImageNote.unload = function(self)

end

ImageNote.draw = function(self)
	if not self:isHere() then
		return
	end
	if self.drawable then
		self.drawable:draw()
	end
end

ImageNote.reload = function(self, event)
	return self.drawable:reload()
end

return ImageNote
