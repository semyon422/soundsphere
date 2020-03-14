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
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Head", "w")
end

ShortGraphicalNote.getHeadHeight = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Head", "h")
end

ShortGraphicalNote.getX = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return
		  self.noteSkin:getG(0, dt, self, "Head", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Head", "ox")
end

ShortGraphicalNote.getY = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
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

ShortGraphicalNote.whereWillDrawX = function(self)
	local shortNoteX = self:getX()
	local shortNoteWidth = self:getHeadWidth()

	local cs = self.noteSkin:getCS(self)
	local allcs = self.noteSkin.allcs
	local x
	if (allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) > 0) and (allcs:x(cs:X(shortNoteX, true), true) < 1) then
		x = 0
	elseif allcs:x(cs:X(shortNoteX, true), true) >= 1 then
		x = 1
	elseif allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) <= 0 then
		x = -1
	end

	return x
end

ShortGraphicalNote.whereWillDrawY = function(self)
	local shortNoteY = self:getY()
	local shortNoteHeight = self:getHeadHeight()
	
	local cs = self.noteSkin:getCS(self)
	local allcs = self.noteSkin.allcs
	local y
	if (allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) > 0) and (allcs:y(cs:Y(shortNoteY, true), true) < 1) then
		y = 0
	elseif allcs:y(cs:Y(shortNoteY, true), true) >= 1 then
		y = 1
	elseif allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) <= 0 then
		y = -1
	end

	return y
end

ShortGraphicalNote.whereWillDrawW = function(self)
	return self.noteSkin:whereWillBelongSegment(self, "Head", "w", self:getHeadWidth())
end

ShortGraphicalNote.whereWillDrawH = function(self)
	return self.noteSkin:whereWillBelongSegment(self, "Head", "h", self:getHeadHeight())
end

ShortGraphicalNote.whereWillDraw = function(self)
	local x = self:whereWillDrawX()
	local y = self:whereWillDrawY()
	local w = self:whereWillDrawW()
	local h = self:whereWillDrawH()
	return x, y, w, h
end

ShortGraphicalNote.willDraw = function(self)
	local x, y, w, h = self:whereWillDraw()
	return
		x == 0 and
		y == 0 and
		w == 0 and
		h == 0
end

ShortGraphicalNote.willDrawBeforeStart = function(self)
	local x, y, w, h = self:whereWillDraw()
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRate = self.noteSkin.visualTimeRate
	return
		self.noteSkin:getG(1, dt, self, "Head", "x") * x * visualTimeRate > 0 or
		self.noteSkin:getG(1, dt, self, "Head", "y") * y * visualTimeRate > 0 or
		w * visualTimeRate > 0 or
		h * visualTimeRate > 0
end

ShortGraphicalNote.willDrawAfterEnd = function(self)
	local x, y, w, h = self:whereWillDraw()
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRate = self.noteSkin.visualTimeRate
	return
		self.noteSkin:getG(1, dt, self, "Head", "x") * x * visualTimeRate < 0 or
		self.noteSkin:getG(1, dt, self, "Head", "y") * y * visualTimeRate < 0 or
		w * visualTimeRate < 0 or
		h * visualTimeRate < 0
end

return ShortGraphicalNote
