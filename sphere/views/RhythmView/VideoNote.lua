local ImageFrame	= require("aqua.graphics.ImageFrame")
local GraphicalNote = require("sphere.views.RhythmView.GraphicalNote")
local ImageNote		= require("sphere.views.RhythmView.ImageNote")
local video			= require("aqua.video")

local VideoNote = GraphicalNote:new()

VideoNote.construct = function(self)
	self.images = self.startNoteData.images
end

VideoNote.timeRate = 0

VideoNote.update = function(self, dt)
	local video = self.video
	if video then
		video:update(dt)
	end

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

VideoNote.activate = function(self)
	local drawable = self:getDrawable()
	if drawable then
		drawable:reload()
		self.drawable = drawable
		self.container = self:getContainer()
		self.container:add(drawable)
	end

	local video = self.video
	if video then
		video:play()
	end
end

VideoNote.deactivate = function(self)
	local drawable = self.drawable
	if drawable then
		self.container:remove(drawable)
	end

	local video = self.video
	if video then
		video:pause()
	end
end

VideoNote.getDrawable = function(self)
	local path = self.graphicEngine.localAliases[self.startNoteData.images[1][1]] or self.graphicEngine.globalAliases[self.startNoteData.images[1][1]]

	local video = video.new(path)
	local image

	if video then
		video:rewind()
		image = video.image

		local drawable = ImageFrame:new({
			image = image,
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

		local deltaTime = self.startNoteData.timePoint.absoluteTime
		video.getAdjustTime = function()
			return self.graphicEngine.currentTime - deltaTime
		end
		video:setRate(self.graphicEngine.timeRate)

		self.video = video
		self.image = image

		return drawable
	end
end


VideoNote.reload = ImageNote.reload
VideoNote.getContainer = ImageNote.getContainer
VideoNote.getHeadWidth = ImageNote.getHeadWidth
VideoNote.getHeadHeight = ImageNote.getHeadHeight
VideoNote.getX = ImageNote.getX
VideoNote.getY = ImageNote.getY
VideoNote.getScaleX = ImageNote.getScaleX
VideoNote.getScaleY = ImageNote.getScaleY
VideoNote.getColor = ImageNote.getColor

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
