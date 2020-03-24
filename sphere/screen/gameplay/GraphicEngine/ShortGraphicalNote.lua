local GraphicalNote = require("sphere.screen.gameplay.GraphicEngine.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	self:computeVisualTime()
	self:computeTimeState()
	
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
	return self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

ShortGraphicalNote.computeTimeState = function(self)
	self.timeState = self.timeState or {}
	local timeState = self.timeState

	timeState.currentTime = self.graphicEngine.currentTime
	timeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	timeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime

	timeState.absoluteDeltaTime = self.graphicEngine.currentTime - self.startNoteData.timePoint.absoluteTime
	timeState.visualDeltaTime = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	timeState.scaledVisualDeltaTime = timeState.visualDeltaTime * self.noteSkin:getVisualTimeRate()
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
	return self.noteSkin:getG(self, "Head", "w", self.timeState)
end

ShortGraphicalNote.getHeadHeight = function(self)
	return self.noteSkin:getG(self, "Head", "h", self.timeState)
end

ShortGraphicalNote.getX = function(self)
	return
		  self.noteSkin:getG(self, "Head", "x", self.timeState)
		+ self.noteSkin:getG(self, "Head", "w", self.timeState)
		* self.noteSkin:getG(self, "Head", "ox", self.timeState)
end

ShortGraphicalNote.getY = function(self)
	return
		  self.noteSkin:getG(self, "Head", "y", self.timeState)
		+ self.noteSkin:getG(self, "Head", "h", self.timeState)
		* self.noteSkin:getG(self, "Head", "oy", self.timeState)
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
	return self.noteSkin:whereWillDraw(self.timeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
