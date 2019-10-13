local ImageFrame	= require("aqua.graphics.ImageFrame")
local Class			= require("aqua.util.Class")
local video			= require("aqua.video")

local VideoNote = Class:new()

VideoNote.getNext = function(self)
	return self.noteHandler.noteData[self.index + 1]
end

VideoNote.next = function(self)
	self.ended = true
	local nextNote = self:getNext()
	if nextNote then
		self.noteHandler.currentNote = nextNote
		nextNote:load()
		return nextNote:update()
	end
end

VideoNote.isHere = function(self)
	return self.noteData.timePoint.absoluteTime <= self.engine.currentTime
end

VideoNote.update = function(self, dt)
	local nextNote = self:getNext()
	if nextNote and nextNote:isHere() then
		return self:next()
	end
	if self.video then
		self.video:update(dt)
	end
end

VideoNote.setRate = function(self, rate)
	if self.video then
		self.video:setRate(rate)
	end
end

VideoNote.pause = function(self)
	if self.video then
		self.video:pause()
	end
end

VideoNote.play = function(self)
	if self.video and self:isHere() then
		self.video:play()
	end
end

VideoNote.load = function(self)
	local path = self.engine.localAliases[self.images[1][1]] or self.engine.globalAliases[self.images[1][1]]
	self.video = video.new(path)
	
	if self.video then
		self.video:rewind()
		
		self.drawable = ImageFrame:new({
			image = self.video.image,
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
		
		local deltaTime = self.noteData.timePoint.absoluteTime
		self.video.getAdjustTime = function()
			return self.engine.currentTime - deltaTime
		end
		self.video:setRate(self.bga.rate)
	end
end

VideoNote.unload = function(self)

end

VideoNote.draw = function(self)
	if not self:isHere() then
		return
	end
	if not self.started then
		if self.video then
			self.video:play()
		end
		self.started = true
	end
	if self.drawable then
		self.drawable:draw()
	end
end

VideoNote.reload = function(self, event)
	return self.drawable:reload()
end

return VideoNote
