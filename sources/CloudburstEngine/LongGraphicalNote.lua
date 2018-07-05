CloudburstEngine.LongGraphicalNote = createClass(CloudburstEngine.GraphicalNote)
local LongGraphicalNote = CloudburstEngine.LongGraphicalNote

LongGraphicalNote.update = function(self)
	if self.noteDrawer.optimisationMode == self.noteDrawer.OptimisationModeEnum.UpdateAll then
		if not self:willDraw() then
			self:deactivate()
		else
			self.headDrawable.y = self:getHeadY()
			self.tailDrawable.y = self:getTailY()
			self.bodyDrawable.y = self:getBodyY()
			self.bodyDrawable.sy = self:getBodyScaleY()
			
			self:updateColour(self.headDrawable.color, self:getColour())
			self:updateColour(self.tailDrawable.color, self:getColour())
			self:updateColour(self.bodyDrawable.color, self:getColour())
		end
	elseif self.noteDrawer.optimisationMode == self.noteDrawer.OptimisationModeEnum.UpdateVisible then
		self:computeVisualTime()
		
		if self:willDrawBeforeStart() and self.index == self.noteDrawer.startNoteIndex then
			self:deactivate()
			self.noteDrawer.startNoteIndex = self.noteDrawer.startNoteIndex + 1
		elseif self:willDrawAfterEnd() and self.index == self.noteDrawer.endNoteIndex then
			self:deactivate()
			self.noteDrawer.endNoteIndex = self.noteDrawer.endNoteIndex - 1
		else
			self.headDrawable.y = self:getHeadY()
			self.tailDrawable.y = self:getTailY()
			self.bodyDrawable.y = self:getBodyY()
			self.bodyDrawable.sy = self:getBodyScaleY()
			
			self:updateColour(self.headDrawable.color, self:getColour())
			self:updateColour(self.tailDrawable.color, self:getColour())
			self:updateColour(self.bodyDrawable.color, self:getColour())
		end
	end
end

LongGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.currentVisualTime
		= (self.startNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
	self.endNoteData.currentVisualTime
		= (self.endNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
end

LongGraphicalNote.activate = function(self)
	self.headDrawable = soul.graphics.Drawable:new({
		cs = self:getCS(),
		x = self:getX(),
		y = self:getHeadY(),
		sx = self:getHeadScaleX(),
		sy = self:getHeadScaleY(),
		drawable = self:getHeadDrawable(),
		layer = self:getHeadLayer(),
		color = {255, 255, 255, 255}
	})
	self.tailDrawable = soul.graphics.Drawable:new({
		cs = self:getCS(),
		x = self:getX(),
		y = self:getTailY(),
		sx = self:getTailScaleX(),
		sy = self:getTailScaleY(),
		drawable = self:getTailDrawable(),
		layer = self:getTailLayer(),
		color = {255, 255, 255, 255}
	})
	self.bodyDrawable = soul.graphics.Drawable:new({
		cs = self:getCS(),
		x = self:getX(),
		y = self:getBodyY(),
		sx = self:getBodyScaleX(),
		sy = self:getBodyScaleY(),
		drawable = self:getBodyDrawable(),
		layer = self:getBodyLayer(),
		color = {255, 255, 255, 255}
	})
	self.headDrawable:activate()
	self.tailDrawable:activate()
	self.bodyDrawable:activate()
	
	self:updateColour(self.headDrawable.color, self:getColour())
	self:updateColour(self.tailDrawable.color, self:getColour())
	self:updateColour(self.bodyDrawable.color, self:getColour())
	
	self.activated = true
end

LongGraphicalNote.deactivate = function(self)
	self.headDrawable:deactivate()
	self.tailDrawable:deactivate()
	self.bodyDrawable:deactivate()
	self.headDrawable = nil
	self.tailDrawable = nil
	self.bodyDrawable = nil
	
	self.activated = false
end

LongGraphicalNote.getColour = function(self)
	return self.engine.noteSkin:getLongNoteColour(self)
end

LongGraphicalNote.getHeadLayer = function(self)
	return self.engine.noteSkin:getLongNoteHeadLayer(self)
end
LongGraphicalNote.getTailLayer = function(self)
	return self.engine.noteSkin:getLongNoteTailLayer(self)
end
LongGraphicalNote.getBodyLayer = function(self)
	return self.engine.noteSkin:getLongNoteBodyLayer(self)
end

LongGraphicalNote.getHeadDrawable = function(self)
	return self.engine.noteSkin:getNoteDrawable(self, "Head")
end
LongGraphicalNote.getTailDrawable = function(self)
	return self.engine.noteSkin:getNoteDrawable(self, "Tail")
end
LongGraphicalNote.getBodyDrawable = function(self)
	return self.engine.noteSkin:getNoteDrawable(self, "Body")
end

LongGraphicalNote.getX = function(self)
	return self.engine.noteSkin:getNoteX(self)
end

LongGraphicalNote.getHeadY = function(self)
	return self.engine.noteSkin:getLongNoteHeadY(self, "Head")
end
LongGraphicalNote.getTailY = function(self)
	return self.engine.noteSkin:getLongNoteTailY(self, "Tail")
end
LongGraphicalNote.getBodyY = function(self)
	return self.engine.noteSkin:getLongNoteBodyY(self, "Body")
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self.engine.noteSkin:getNoteScaleX(self, "Head")
end
LongGraphicalNote.getTailScaleX = function(self)
	return self.engine.noteSkin:getNoteScaleX(self, "Tail")
end
LongGraphicalNote.getBodyScaleX = function(self)
	return self.engine.noteSkin:getNoteScaleX(self, "Body")
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self.engine.noteSkin:getNoteScaleY(self, "Head")
end
LongGraphicalNote.getTailScaleY = function(self)
	return self.engine.noteSkin:getNoteScaleY(self, "Tail")
end
LongGraphicalNote.getBodyScaleY = function(self)
	return self.engine.noteSkin:getNoteScaleY(self, "Body")
end

LongGraphicalNote.willDraw = function(self)
	return self.engine.noteSkin:willLongNoteDraw(self)
end
LongGraphicalNote.willDrawBeforeStart = function(self)
	return self.engine.noteSkin:willLongNoteDrawBeforeStart(self)
end
LongGraphicalNote.willDrawAfterEnd = function(self)
	return self.engine.noteSkin:willLongNoteDrawAfterEnd(self)
end
