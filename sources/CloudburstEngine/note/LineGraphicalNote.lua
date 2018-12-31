CloudburstEngine.LineGraphicalNote = createClass(CloudburstEngine.GraphicalNote)
local LineGraphicalNote = CloudburstEngine.LineGraphicalNote

LineGraphicalNote.update = function(self)
	if self.noteDrawer.optimisationMode == self.noteDrawer.OptimisationModeEnum.UpdateAll then
		if not self:willDraw() then
			self:deactivate()
		else
			self.rectangle.x = self:getX()
			self.rectangle.y = self:getY()
		end
	elseif self.noteDrawer.optimisationMode == self.noteDrawer.OptimisationModeEnum.UpdateVisible then
		self:computeVisualTime()
		
		if self:willDrawBeforeStart() and self.index == self.noteDrawer.startNoteIndex then
			self:deactivate()
			self.noteDrawer.startNoteIndex = self.noteDrawer.startNoteIndex + 1
			self:updateNext(self.noteDrawer.startNoteIndex)
		elseif self:willDrawAfterEnd() and self.index == self.noteDrawer.endNoteIndex then
			self:deactivate()
			self.noteDrawer.endNoteIndex = self.noteDrawer.endNoteIndex - 1
			self:updateNext(self.noteDrawer.endNoteIndex)
		else
			self.rectangle.x = self:getX()
			self.rectangle.y = self:getY()
		end
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
	return self.engine.noteSkin:getShortNoteLayer(self)
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
