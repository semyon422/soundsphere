local GraphicalNote = require("sphere.screen.gameplay.CloudburstEngine.note.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	self:computeVisualTime()
	
	if self.index == self.noteDrawer.startNoteIndex and self:willDrawBeforeStart() then
		self:deactivate()
		self.noteDrawer.startNoteIndex = self.noteDrawer.startNoteIndex + 1
		return self:updateNext(self.noteDrawer.startNoteIndex)
	elseif self.index == self.noteDrawer.endNoteIndex and self:willDrawAfterEnd() then
		self:deactivate()
		self.noteDrawer.endNoteIndex = self.noteDrawer.endNoteIndex - 1
		return self:updateNext(self.noteDrawer.endNoteIndex)
	else
		self.drawable.y = self:getY()
		self.drawable.x = self:getX()
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

ShortGraphicalNote.getLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Head")
end

ShortGraphicalNote.getDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Head")
end

ShortGraphicalNote.getContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Head")
end

ShortGraphicalNote.getX = function(self)
	local data = self.noteSkin.data[self.id]["Head"]
	return
		data.x
		+ data.fx * self.noteSkin:getVisualTimeRate()
			* (self.startNoteData.timePoint.currentVisualTime - self.engine.currentTime)
		+ data.ox * self.noteSkin:getNoteWidth(self, "Head")
end

ShortGraphicalNote.getY = function(self)
	local data = self.noteSkin.data[self.id]["Head"]
	return
		data.y
		+ data.fy * self.noteSkin:getVisualTimeRate()
			* (self.startNoteData.timePoint.currentVisualTime - self.engine.currentTime)
		+ data.oy * self.noteSkin:getNoteHeight(self, "Head")
end

ShortGraphicalNote.getScaleX = function(self)
	return
		self.noteSkin:getNoteWidth(self, "Head") /
		self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Head"):getWidth())
end

ShortGraphicalNote.getScaleY = function(self)
	return
		self.noteSkin:getNoteHeight(self, "Head") /
		self.noteSkin:getCS(self):y(self:getNoteImage(self, "Head"):getHeight())
end

ShortGraphicalNote.whereWillDraw = function(self)
	local shortNoteY = self:getY()
	local shortNoteHeight = self.noteSkin:getNoteHeight(self, "Head")
	local shortNoteX = self:getX()
	local shortNoteWidth = self.noteSkin:getNoteWidth(self, "Head")
	
	local cs = self.noteSkin:getCS(self)
	
	local allcs = self.noteSkin.allcs
	local x, y
	if (allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) > 0) and (allcs:x(cs:X(shortNoteX, true), true) < 1) then
		x = 0
	elseif allcs:x(cs:X(shortNoteX, true), true) >= 1 then
		x = 1
	elseif allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) <= 0 then
		x = -1
	end
	if (allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) > 0) and (allcs:y(cs:Y(shortNoteY, true), true) < 1) then
		y = 0
	elseif allcs:y(cs:Y(shortNoteY, true), true) >= 1 then
		y = 1
	elseif allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) <= 0 then
		y = -1
	end
	
	return x, y
end
ShortGraphicalNote.willDraw = function(self)
	local x, y = self:whereWillDraw(self)
	return x == 0 and y == 0
end

ShortGraphicalNote.willDrawBeforeStart = function(self)
	local x, y = self:whereWillDraw(self)
	local data = self.noteSkin.data[self.id]["Head"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	return data.fx * x * visualTimeRate < 0 or data.fy * y * visualTimeRate < 0
end

ShortGraphicalNote.willDrawAfterEnd = function(self)
	local x, y = self:whereWillDraw(self)
	local data = self.noteSkin.data[self.id]["Head"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	return data.fx * x * visualTimeRate > 0 or data.fy * y * visualTimeRate > 0
end

return ShortGraphicalNote
