local GraphicalNote = require("sphere.screen.gameplay.CloudburstEngine.note.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.update = function(self)
	self:computeVisualTime()
	
	if not self:tryNext() then
		self.headDrawable.x = self:getHeadX()
		self.tailDrawable.x = self:getTailX()
		self.bodyDrawable.x = self:getBodyX()
		self.headDrawable.sx = self:getHeadScaleX()
		self.tailDrawable.sx = self:getTailScaleX()
		self.bodyDrawable.sx = self:getBodyScaleX()
		
		self.headDrawable.y = self:getHeadY()
		self.tailDrawable.y = self:getTailY()
		self.bodyDrawable.y = self:getBodyY()
		self.headDrawable.sy = self:getHeadScaleY()
		self.tailDrawable.sy = self:getTailScaleY()
		self.bodyDrawable.sy = self:getBodyScaleY()
		
		self.headDrawable:reload()
		self.tailDrawable:reload()
		self.bodyDrawable:reload()
		
		local color = self:getColor()
		self.headDrawable.color = color
		self.tailDrawable.color = color
		self.bodyDrawable.color = color
	end
end

LongGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	self.endNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

LongGraphicalNote.updateFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	local endTime = self.endNoteData.timePoint.absoluteTime
	self.fakeStartTime = self.engine.currentTime > startTime and self.engine.currentTime or startTime
	self.fakeStartTime = math.min(self.fakeStartTime, endTime)
end

LongGraphicalNote.getFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	if self.logicalNote.state == "startPassedPressed" then
		self:updateFakeStartTime()
		return self.fakeStartTime
	else
		return self.fakeStartTime or self.startNoteData.timePoint.absoluteTime
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
		= (fakeStartTime - fakeVelocityData.timePoint.absoluteTime)
		* fakeVelocityData.currentSpeed
		+ fakeVelocityData.timePoint.zeroClearVisualTime
		
	local fakeVisualStartTime
		= (fakeVisualClearStartTime - self.noteDrawer.currentTimePoint.zeroClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint.absoluteTime
		
	return fakeVisualStartTime
end

LongGraphicalNote.activate = function(self)
	self.headDrawable = self:getHeadDrawable()
	self.tailDrawable = self:getTailDrawable()
	self.bodyDrawable = self:getBodyDrawable()
	self.headDrawable:reload()
	self.tailDrawable:reload()
	self.bodyDrawable:reload()
	self.headContainer = self:getHeadContainer()
	self.tailContainer = self:getTailContainer()
	self.bodyContainer = self:getBodyContainer()
	self.headContainer:add(self.headDrawable)
	self.tailContainer:add(self.tailDrawable)
	self.bodyContainer:add(self.bodyDrawable)
	
	self.activated = true
end

LongGraphicalNote.deactivate = function(self)
	self.headContainer:remove(self.headDrawable)
	self.tailContainer:remove(self.tailDrawable)
	self.bodyContainer:remove(self.bodyDrawable)
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
	local logicalNote = self.logicalNote
	
	local color = self.noteSkin.color
	if self.fakeStartTime and self.fakeStartTime >= self.endNoteData.timePoint.absoluteTime then
		return color.transparent
	elseif logicalNote.state == "clear" then
		return color.clear
	elseif logicalNote.state == "startMissed" then
		return color.startMissed
	elseif logicalNote.state == "startMissedPressed" then
		return color.startMissedPressed
	elseif logicalNote.state == "startPassedPressed" then
		return color.startPassedPressed
	elseif logicalNote.state == "endPassed" then
		return color.endPassed
	elseif logicalNote.state == "endMissed" then
		return color.endMissed
	elseif logicalNote.state == "endMissedPassed" then
		return color.endMissedPassed
	end

	return color.clear
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
	return self.noteSkin:getImageDrawable(self, "Head")
end

LongGraphicalNote.getTailDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Tail")
end

LongGraphicalNote.getBodyDrawable = function(self)
	return self.noteSkin:getImageDrawable(self, "Body")
end

LongGraphicalNote.getHeadContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Head")
end

LongGraphicalNote.getTailContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Tail")
end

LongGraphicalNote.getBodyContainer = function(self)
	return self.noteSkin:getImageContainer(self, "Body")
end

LongGraphicalNote.getHeadWidth = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Head", "w")
end

LongGraphicalNote.getTailHeight = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Tail", "w")
end

LongGraphicalNote.getBodyWidth = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Body", "w")
end

LongGraphicalNote.getHeadHeight = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Head", "h")
end

LongGraphicalNote.getTailWidth = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Tail", "h")
end

LongGraphicalNote.getBodyHeight = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	return self.noteSkin:getG(0, dt, self, "Body", "h")
end

LongGraphicalNote.getHeadX = function(self)
	local dt = self.engine.currentTime - (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime)
	return
		  self.noteSkin:getG(0, dt, self, "Head", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Head", "ox")
end

LongGraphicalNote.getTailX = function(self)
	local dt = self.engine.currentTime - self.endNoteData.timePoint.currentVisualTime
	return
		  self.noteSkin:getG(0, dt, self, "Tail", "x")
		+ self.noteSkin:getG(0, dt, self, "Tail", "w")
		* self.noteSkin:getG(0, dt, self, "Tail", "ox")
end

LongGraphicalNote.getBodyX = function(self)
	local dg = self:getHeadX() - self:getTailX()
	local dt
	if dg >= 0 then
		dt = self.engine.currentTime - self.endNoteData.timePoint.currentVisualTime
	else
		dt = self.engine.currentTime - (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime)
	end
	return
		  self.noteSkin:getG(0, dt, self, "Body", "x")
		+ self.noteSkin:getG(0, dt, self, "Head", "w")
		* self.noteSkin:getG(0, dt, self, "Body", "ox")
end

LongGraphicalNote.getHeadY = function(self)
	local dt = self.engine.currentTime - (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime)
	return
		  self.noteSkin:getG(0, dt, self, "Head", "y")
		+ self.noteSkin:getG(0, dt, self, "Head", "h")
		* self.noteSkin:getG(0, dt, self, "Head", "oy")
end

LongGraphicalNote.getTailY = function(self)
	local dt = self.engine.currentTime - self.endNoteData.timePoint.currentVisualTime
	return
		  self.noteSkin:getG(0, dt, self, "Tail", "y")
		+ self.noteSkin:getG(0, dt, self, "Tail", "h")
		* self.noteSkin:getG(0, dt, self, "Tail", "oy")
end

LongGraphicalNote.getBodyY = function(self)
	local dg = self:getHeadY() - self:getTailY()
	local dt
	if dg >= 0 then
		dt = self.engine.currentTime - self.endNoteData.timePoint.currentVisualTime
	else
		dt = self.engine.currentTime - (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime)
	end
	return
		  self.noteSkin:getG(0, dt, self, "Body", "y")
		+ self.noteSkin:getG(0, dt, self, "Head", "h")
		* self.noteSkin:getG(0, dt, self, "Body", "oy")
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self:getHeadWidth() / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Head"):getWidth())
end

LongGraphicalNote.getTailScaleX = function(self)
	return self:getTailWidth() / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Tail"):getWidth())
end

LongGraphicalNote.getBodyScaleX = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRateSign = self.noteSkin:getVisualTimeRateSign()
	return
		(
			math.max(
				(self:getHeadX() - self:getTailX()) * visualTimeRateSign,
				0
			)
			+ self.noteSkin:getG(0, dt, self, "Body", "w")
		) / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Body"):getWidth())
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self:getHeadHeight() / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Head"):getHeight())
end

LongGraphicalNote.getTailScaleY = function(self)
	return self:getTailHeight() / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Tail"):getHeight())
end

LongGraphicalNote.getBodyScaleY = function(self)
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRateSign = self.noteSkin:getVisualTimeRateSign()
	return
		(
			math.max(
				(self:getHeadY() - self:getTailY()) * visualTimeRateSign,
				0
			)
			+ self.noteSkin:getG(0, dt, self, "Body", "h")
		) / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Body"):getHeight())
end

LongGraphicalNote.whereWillDrawX = function(self)
	local longNoteHeadX = self:getHeadX()
	local longNoteTailX = self:getTailX()
	local longNoteHeadWidth = self:getHeadWidth()
	local longNoteTailWidth = self:getTailWidth()
	
	local cs = self.noteSkin:getCS(self)
	local allcs = self.noteSkin.allcs
	local x
	if
		(allcs:x(cs:X(longNoteHeadX + longNoteHeadWidth, true), true) > 0) and (allcs:x(cs:X(longNoteHeadX, true), true) < 1) or
		(allcs:x(cs:X(longNoteTailX + longNoteTailWidth, true), true) > 0) and (allcs:x(cs:X(longNoteTailX, true), true) < 1) or
		allcs:x(cs:X(longNoteTailX + longNoteTailWidth, true), true) * allcs:x(cs:X(longNoteHeadX, true), true) < 0
	then
		x = 0
	elseif allcs:x(cs:X(longNoteTailX, true), true) >= 1 then
		x = 1
	elseif allcs:x(cs:X(longNoteHeadX + longNoteHeadWidth, true), true) <= 0 then
		x = -1
	end
	
	return x
end

LongGraphicalNote.whereWillDrawY = function(self)
	local longNoteHeadY = self:getHeadY()
	local longNoteTailY = self:getTailY()
	local longNoteHeadHeight = self:getHeadHeight()
	local longNoteTailHeight = self:getTailHeight()
	
	local cs = self.noteSkin:getCS(self)
	local allcs = self.noteSkin.allcs
	local y
	if
		(allcs:y(cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) > 0) and (allcs:y(cs:Y(longNoteHeadY, true), true) < 1) or
		(allcs:y(cs:Y(longNoteTailY + longNoteTailHeight, true), true) > 0) and (allcs:y(cs:Y(longNoteTailY, true), true) < 1) or
		allcs:y(cs:Y(longNoteTailY + longNoteTailHeight, true), true) * allcs:y(cs:Y(longNoteHeadY, true), true) < 0
	then
		y = 0
	elseif allcs:y(cs:Y(longNoteTailY, true), true) >= 1 then
		y = 1
	elseif allcs:y(cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) <= 0 then
		y = -1
	end
	
	return y
end

LongGraphicalNote.whereWillDrawW = function(self)
	local head = self.noteSkin:whereWillBelongSegment(self, "Head", "w", self:getHeadWidth())
	local tail = self.noteSkin:whereWillBelongSegment(self, "Head", "w", self:getHeadWidth())
	local body = self.noteSkin:whereWillBelongSegment(self, "Head", "w", self:getHeadWidth())

	if head == 0 or tail == 0 or body == 0 or head * tail < 0 then
		return 0
	elseif head < 0 then
		return -1
	elseif tail > 0 then
		return 1
	end
end

LongGraphicalNote.whereWillDrawH = function(self)
	local head = self.noteSkin:whereWillBelongSegment(self, "Head", "h", self:getHeadWidth())
	local tail = self.noteSkin:whereWillBelongSegment(self, "Head", "h", self:getHeadWidth())
	local body = self.noteSkin:whereWillBelongSegment(self, "Head", "h", self:getHeadWidth())

	if head == 0 or tail == 0 or body == 0 or head * tail < 0 then
		return 0
	elseif head < 0 then
		return -1
	elseif tail > 0 then
		return 1
	end
end

LongGraphicalNote.whereWillDraw = function(self)
	local x = self:whereWillDrawX()
	local y = self:whereWillDrawY()
	local w = self:whereWillDrawW()
	local h = self:whereWillDrawH()
	return x, y, w, h
end

LongGraphicalNote.willDraw = function(self)
	local x, y, w, h = self:whereWillDraw()
	return
		x == 0 and
		y == 0 and
		w == 0 and
		h == 0
end

LongGraphicalNote.willDrawBeforeStart = function(self)
	local x, y, w, h = self:whereWillDraw()
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRate = self.noteSkin.visualTimeRate
	return
		self.noteSkin:getG(1, dt, self, "Head", "x") * x * visualTimeRate > 0 or
		self.noteSkin:getG(1, dt, self, "Head", "x") * y * visualTimeRate > 0 or
		w * visualTimeRate > 0 or
		h * visualTimeRate > 0
end

LongGraphicalNote.willDrawAfterEnd = function(self)
	local x, y, w, h = self:whereWillDraw()
	local dt = self.engine.currentTime - self.startNoteData.timePoint.currentVisualTime
	local visualTimeRate = self.noteSkin.visualTimeRate
	return
		self.noteSkin:getG(1, dt, self, "Head", "x") * x * visualTimeRate < 0 or
		self.noteSkin:getG(1, dt, self, "Head", "y") * y * visualTimeRate < 0 or
		w * visualTimeRate < 0 or
		h * visualTimeRate < 0
end

return LongGraphicalNote
