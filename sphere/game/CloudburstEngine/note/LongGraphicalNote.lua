local Drawable = require("aqua.graphics.Drawable")
local GraphicalNote = require("sphere.game.CloudburstEngine.note.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.update = function(self)
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
		self.headDrawable.x = self:getHeadX()
		self.tailDrawable.x = self:getTailX()
		self.bodyDrawable.x = self:getBodyX()
		self.bodyDrawable.sx = self:getBodyScaleX()
		
		self.headDrawable.y = self:getHeadY()
		self.tailDrawable.y = self:getTailY()
		self.bodyDrawable.y = self:getBodyY()
		self.bodyDrawable.sy = self:getBodyScaleY()
		
		self.headDrawable:reload()
		self.tailDrawable:reload()
		self.bodyDrawable:reload()
		
		local color = self:getColor()
		self:updateColor(self.headDrawable.color, color)
		self:updateColor(self.tailDrawable.color, color)
		self:updateColor(self.bodyDrawable.color, color)
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

LongGraphicalNote.updateFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint:getAbsoluteTime()
	local endTime = self.endNoteData.timePoint:getAbsoluteTime()
	self.fakeStartTime = self.engine.currentTime > startTime and self.engine.currentTime or startTime
	self.fakeStartTime = math.min(self.fakeStartTime, endTime)
end

LongGraphicalNote.getFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint:getAbsoluteTime()
	if self.logicalNote.state == "startPassedPressed" then
		self:updateFakeStartTime()
		return self.fakeStartTime
	else
		return self.fakeStartTime or self.startNoteData.timePoint:getAbsoluteTime()
	end
end

LongGraphicalNote.getFakeVelocityData = function(self)
	if self.logicalNote.state == "startPassedPressed" and self.fakeStartTime then
		return "current"
	else
		return self.fakeVelocityData or self.startNoteData.timePoint.velocityData
	end
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local fakeStartTime = self:getFakeStartTime()
	local fakeVelocityData = self:getFakeVelocityData()
	if fakeVelocityData == "current" then
		fakeVelocityData = self.noteDrawer.currentVelocityData
		self.fakeVelocityData = fakeVelocityData
	end
	
	local fakeVisualClearStartTime
		= (fakeStartTime - fakeVelocityData.timePoint:getAbsoluteTime())
		* fakeVelocityData.currentSpeed:tonumber()
		+ fakeVelocityData.timePoint.zeroClearVisualTime
		
	local fakeVisualStartTime
		= (fakeVisualClearStartTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
		
	return fakeVisualStartTime
end

LongGraphicalNote.activate = function(self)
	self.headDrawable = Drawable:new({
		cs = self:getCS(),
		x = self:getHeadX(),
		y = self:getHeadY(),
		sx = self:getHeadScaleX(),
		sy = self:getHeadScaleY(),
		drawable = self:getHeadDrawable(),
		layer = self:getHeadLayer(),
		color = {255, 255, 255, 255}
	})
	self.tailDrawable = Drawable:new({
		cs = self:getCS(),
		x = self:getTailX(),
		y = self:getTailY(),
		sx = self:getTailScaleX(),
		sy = self:getTailScaleY(),
		drawable = self:getTailDrawable(),
		layer = self:getTailLayer(),
		color = {255, 255, 255, 255}
	})
	self.bodyDrawable = Drawable:new({
		cs = self:getCS(),
		x = self:getBodyX(),
		y = self:getBodyY(),
		sx = self:getBodyScaleX(),
		sy = self:getBodyScaleY(),
		drawable = self:getBodyDrawable(),
		layer = self:getBodyLayer(),
		color = {255, 255, 255, 255}
	})
	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()
	self.container:add(self.headDrawable)
	self.container:add(self.tailDrawable)
	self.container:add(self.bodyDrawable)
	
	self:updateColor(self.headDrawable.color, self:getColor())
	self:updateColor(self.tailDrawable.color, self:getColor())
	self:updateColor(self.bodyDrawable.color, self:getColor())
	
	self.activated = true
end

LongGraphicalNote.deactivate = function(self)
	self.container:remove(self.headDrawable)
	self.container:remove(self.tailDrawable)
	self.container:remove(self.bodyDrawable)
	self.activated = false
end

LongGraphicalNote.reload = function(self)
	self.headDrawable.sx = self:getHeadScaleX()
	self.headDrawable.sy = self:getHeadScaleY()
	self.tailDrawable.sx = self:getTailScaleX()
	self.tailDrawable.sy = self:getTailScaleY()
	self.bodyDrawable.sx = self:getBodyScaleX()
	self.bodyDrawable.sy = self:getBodyScaleY()
	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()
end

LongGraphicalNote.getColor = function(self)
	return self.noteSkin:getLongNoteColor(self)
end

LongGraphicalNote.getHeadLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Head")
end
LongGraphicalNote.getTailLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Tail")
end
LongGraphicalNote.getBodyLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Body")
end

LongGraphicalNote.getHeadDrawable = function(self)
	return self.noteSkin:getNoteDrawable(self, "Head")
end
LongGraphicalNote.getTailDrawable = function(self)
	return self.noteSkin:getNoteDrawable(self, "Tail")
end
LongGraphicalNote.getBodyDrawable = function(self)
	return self.noteSkin:getNoteDrawable(self, "Body")
end

LongGraphicalNote.getHeadX = function(self)
	return self.noteSkin:getLongNoteHeadX(self)
end
LongGraphicalNote.getTailX = function(self)
	return self.noteSkin:getLongNoteTailX(self)
end
LongGraphicalNote.getBodyX = function(self)
	return self.noteSkin:getLongNoteBodyX(self)
end

LongGraphicalNote.getHeadY = function(self)
	return self.noteSkin:getLongNoteHeadY(self)
end
LongGraphicalNote.getTailY = function(self)
	return self.noteSkin:getLongNoteTailY(self)
end
LongGraphicalNote.getBodyY = function(self)
	return self.noteSkin:getLongNoteBodyY(self)
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self.noteSkin:getNoteScaleX(self, "Head")
end
LongGraphicalNote.getTailScaleX = function(self)
	return self.noteSkin:getNoteScaleX(self, "Tail")
end
LongGraphicalNote.getBodyScaleX = function(self)
	return self.noteSkin:getNoteScaleX(self, "Body")
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self.noteSkin:getNoteScaleY(self, "Head")
end
LongGraphicalNote.getTailScaleY = function(self)
	return self.noteSkin:getNoteScaleY(self, "Tail")
end
LongGraphicalNote.getBodyScaleY = function(self)
	return self.noteSkin:getNoteScaleY(self, "Body")
end

LongGraphicalNote.willDraw = function(self)
	return self.noteSkin:willLongNoteDraw(self)
end
LongGraphicalNote.willDrawBeforeStart = function(self)
	return self.noteSkin:willLongNoteDrawBeforeStart(self)
end
LongGraphicalNote.willDrawAfterEnd = function(self)
	return self.noteSkin:willLongNoteDrawAfterEnd(self)
end

return LongGraphicalNote
