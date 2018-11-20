CloudburstEngine.ShortGraphicalNote = createClass(CloudburstEngine.GraphicalNote)
local ShortGraphicalNote = CloudburstEngine.ShortGraphicalNote

ShortGraphicalNote.update = function(self)
	if self.noteDrawer.optimisationMode == self.noteDrawer.OptimisationModeEnum.UpdateAll then
		if not self:willDraw() then
			self:deactivate()
		else
			self.drawable.y = self:getY()
			self.drawable.x = self:getX()
			self:updateColour(self.drawable.color, self:getColour())
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
			self.drawable.y = self:getY()
			self.drawable.x = self:getX()
			self:updateColour(self.drawable.color, self:getColour())
		end
	end
end

ShortGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.currentVisualTime
		= (self.startNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
end

ShortGraphicalNote.activate = function(self)
	self.drawable = soul.graphics.Drawable:new({
		cs = self:getCS(),
		x = self:getX(),
		y = self:getY(),
		sx = self:getScaleX(),
		sy = self:getScaleY(),
		drawable = self:getDrawable(),
		layer = self:getLayer(),
		color = {255, 255, 255, 255}
	})
	self.drawable:activate()
	
	self:updateColour(self.drawable.color, self:getColour())
	
	self.activated = true
end

ShortGraphicalNote.deactivate = function(self)
	self.drawable:deactivate()
	self.drawable = nil
	
	self.activated = false
end

ShortGraphicalNote.getColour = function(self)
	return self.engine.noteSkin:getShortNoteColour(self)
end

ShortGraphicalNote.getLayer = function(self)
	return self.engine.noteSkin:getShortNoteLayer(self)
end

ShortGraphicalNote.getDrawable = function(self)
	return self.engine.noteSkin:getNoteDrawable(self)
end

ShortGraphicalNote.getX = function(self)
	return self.engine.noteSkin:getShortNoteX(self)
end

ShortGraphicalNote.getY = function(self)
	return self.engine.noteSkin:getShortNoteY(self)
end

ShortGraphicalNote.getScaleX = function(self)
	return self.engine.noteSkin:getNoteScaleX(self)
end

ShortGraphicalNote.getScaleY = function(self)
	return self.engine.noteSkin:getNoteScaleY(self)
end

ShortGraphicalNote.willDraw = function(self)
	return self.engine.noteSkin:willShortNoteDraw(self)
end

ShortGraphicalNote.willDrawBeforeStart = function(self)
	return self.engine.noteSkin:willShortNoteDrawBeforeStart(self)
end

ShortGraphicalNote.willDrawAfterEnd = function(self)
	return self.engine.noteSkin:willShortNoteDrawAfterEnd(self)
end
