local GraphicalNote = require("sphere.screen.gameplay.GraphicEngine.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	self:computeVisualTime()
	
	if not self:tryNext() then
		self.drawable.x = self:getX()
		self.drawable.y = self:getY()
		self.drawable.sx = self:getScaleX()
		self.drawable.sy = self:getScaleY()
		self.drawable:reload()
		self.drawable.color = self:getColor()
	end
end

ShortGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	
	self.dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
end

ShortGraphicalNote.activate = function(self)
	self.drawable = self:getDrawable()
	self.drawable:reload()
	self.container = self:getContainer()
	self.container:add(self.drawable)
	
	self.activated = true
end

ShortGraphicalNote.deactivate = function(self)
	self.container:remove(self.drawable)
	self.activated = false
end

ShortGraphicalNote.reload = function(self)
	self.drawable.sx = self:getScaleX()
	self.drawable.sy = self:getScaleY()
	self.drawable:reload()
end

ShortGraphicalNote.getColor = function(self)
	local color = self.noteSkin.color
	if self.logicalNote.state == "clear" or self.logicalNote.state == "skipped" then
		return color.clear
	elseif self.logicalNote.state == "missed" then
		return color.missed
	elseif self.logicalNote.state == "passed" then
		return color.passed
	end
end

ShortGraphicalNote.getDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Head")
end

ShortGraphicalNote.getContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Head")
end

ShortGraphicalNote.getHeadWidth = function(self)
	return self.noteSkin:getG(0, self.dt, self, "Head", "w")
end

ShortGraphicalNote.getHeadHeight = function(self)
	return self.noteSkin:getG(0, self.dt, self, "Head", "h")
end

ShortGraphicalNote.getX = function(self)
	local dt = self.dt
	return
		  self.noteSkin:getG(0, dt, self, "Head", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Head", "ox")
end

ShortGraphicalNote.getY = function(self)
	local dt = self.dt
	return
		  self.noteSkin:getG(0, dt, self, "Head", "y")
		+ self.noteSkin:getG(0, dt, self, "Head", "h")
		* self.noteSkin:getG(0, dt, self, "Head", "oy")
end

ShortGraphicalNote.getScaleX = function(self)
	return
		self:getHeadWidth() /
		self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Head"):getWidth())
end

ShortGraphicalNote.getScaleY = function(self)
	return
		self:getHeadHeight() /
		self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Head"):getHeight())
end

ShortGraphicalNote.whereWillDraw = function(self)
	return self.noteSkin:whereWillDraw(self, self.dt)
end

return ShortGraphicalNote
