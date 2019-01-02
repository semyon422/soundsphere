CloudburstEngine.LineGraphicalNote = createClass(CloudburstEngine.GraphicalNote)
local LineGraphicalNote = CloudburstEngine.LineGraphicalNote

LineGraphicalNote.update = function(self)
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
		self.rectangle.x = self:getX()
		self.rectangle.y = self:getY()
	end
end

LineGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.currentVisualTime
		= (self.startNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
	self.endNoteData.currentVisualTime
		= (self.endNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
end

LineGraphicalNote.activate = function(self)
	self.rectangle = soul.graphics.Rectangle:new({
		cs = self:getCS(),
		mode = "fill",
		x = self:getX(),
		y = self:getY(),
		w = self:getWidth(),
		h = self:getHeight(),
		lineStyle = "rough",
		lineWidth = 1,
		layer = self:getLayer(),
		color = {255, 255, 255, 255}
	})
	self.rectangle:activate()
	
	self.activated = true
end

LineGraphicalNote.deactivate = function(self)
	self.rectangle:deactivate()
	self.rectangle = nil
	
	self.activated = false
end

LineGraphicalNote.getLayer = function(self)
	return self.engine.noteSkin:getNoteLayer(self, "Head")
end
LineGraphicalNote.getX = function(self)
	return self.engine.noteSkin:getLineNoteX(self)
end
LineGraphicalNote.getY = function(self)
	return self.engine.noteSkin:getLineNoteY(self)
end
LineGraphicalNote.getWidth = function(self)
	return self.engine.noteSkin:getLineNoteScaledWidth(self)
end
LineGraphicalNote.getHeight = function(self)
	return self.engine.noteSkin:getLineNoteScaledHeight(self)
end

LineGraphicalNote.willDraw = function(self)
	return self.engine.noteSkin:willLineNoteDraw(self)
end
LineGraphicalNote.willDrawBeforeStart = function(self)
	return self.engine.noteSkin:willLineNoteDrawBeforeStart(self)
end
LineGraphicalNote.willDrawAfterEnd = function(self)
	return self.engine.noteSkin:willLineNoteDrawAfterEnd(self)
end
