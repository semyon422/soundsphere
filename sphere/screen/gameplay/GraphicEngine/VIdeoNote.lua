local ImageFrame	= require("aqua.graphics.ImageFrame")
local GraphicalNote = require("sphere.screen.gameplay.GraphicEngine.GraphicalNote")
local video			= require("aqua.video")

local VideoNote = GraphicalNote:new()

VideoNote.timeRate = 0

VideoNote.update = function(self)
	if not self:tryNext() then
		if self.video then
			self.video:update(dt)
		end
		self.drawable.x = self:getX()
		self.drawable.y = self:getY()
		self.drawable.sx = self:getScaleX()
		self.drawable.sy = self:getScaleY()
		self.drawable:reload()
		self.drawable.color = {255, 255, 255}
	end
end

VideoNote.activate = function(self)
	self.drawable = self:getDrawable()
	self.drawable:reload()
	self.container = self:getContainer()
	self.container:add(self.drawable)
	
	self.activated = true
	if self.video then
		self.video:play()
	end
end

VideoNote.deactivate = function(self)
	self.container:remove(self.drawable)
	self.activated = false
	if self.video then
		self.video:pause()
	end
end

VideoNote.reload = function(self)
	self.drawable.sx = self:getScaleX()
	self.drawable.sy = self:getScaleY()
	self.drawable:reload()
end

VideoNote.computeVisualTime = function(self)
end

VideoNote.getContainer = function(self)
	return self.graphicEngine.container
end

VideoNote.getDrawable = function(self)
	local path = self.graphicEngine.localAliases[self.startNoteData.images[1][1]] or self.graphicEngine.globalAliases[self.startNoteData.images[1][1]]

	self.video = video.new(path)
	
	if self.video then
		self.video:rewind()
		self.image = self.video.image

		local drawable = ImageFrame:new({
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
		
		local deltaTime = self.startNoteData.timePoint.absoluteTime
		self.video.getAdjustTime = function()
			return self.graphicEngine.currentTime - deltaTime
		end
		self.video:setRate(self.graphicEngine.timeRate)

		return drawable
	end
end

VideoNote.willDrawBeforeStart = function(self)
	local nextNote = self:getNext(1)

	if not nextNote then
		return false
	end

	return not nextNote:willDrawAfterEnd()
end

VideoNote.willDrawAfterEnd = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.absoluteTime

	if dt < 0 then
		return true
	end
end

VideoNote.getHeadWidth = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "w")
end

VideoNote.getHeadHeight = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "h")
end

VideoNote.getX = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "x")
end

VideoNote.getY = function(self)
	return self.noteSkin:getG(0, 0, self, "Head", "y")
end

VideoNote.getScaleX = function(self)
	return
		self:getHeadWidth() /
		self.noteSkin:getCS(self):x(self.image:getWidth())
end

VideoNote.getScaleY = function(self)
	return
		self:getHeadHeight() /
		self.noteSkin:getCS(self):y(self.image:getHeight())
end

VideoNote.receive = function(self, event)
	if event.name == "TimeState" then
		self:setTimeRate(event.timeRate)
		self.timeRate = event.timeRate
	end
end

VideoNote.setTimeRate = function(self, timeRate)
	local video = self.video
	if not video then
		return
	end

	if timeRate == 0 and self.timeRate ~= 0 then
		video:pause()
	elseif timeRate ~= 0 and self.timeRate == 0 then
		video:setRate(timeRate)
		video:play()
	elseif timeRate ~= 0 and self.timeRate ~= 0 then
		video:setRate(timeRate)
	end
end

return VideoNote
