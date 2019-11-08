local GraphicalNote = require("sphere.screen.gameplay.CloudburstEngine.note.GraphicalNote")

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

LongGraphicalNote.getHeadX = function(self)
	local data = self.noteSkin.data[self.id]["Head"]
	return
		data.x
		+ data.fx * self.noteSkin:getVisualTimeRate()
			* ((self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime) - self.engine.currentTime)
		+ data.ox * self.noteSkin:getNoteWidth(self, "Head")
end
LongGraphicalNote.getTailX = function(self)
	local dataHead = self.noteSkin.data[self.id]["Head"]
	local dataTail = self.noteSkin.data[self.id]["Tail"]
	return
		dataHead.x
		+ dataHead.fx * self.noteSkin:getVisualTimeRate()
			* (self.endNoteData.timePoint.currentVisualTime - self.engine.currentTime)
		+ dataTail.ox * self.noteSkin:getNoteWidth(self, "Tail")
end
LongGraphicalNote.getBodyX = function(self)
	local dataHead = self.noteSkin.data[self.id]["Head"]
	local dataBody = self.noteSkin.data[self.id]["Body"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	local dt
	if dataHead.fx * visualTimeRate <= 0 then
		dt = self.endNoteData.timePoint.currentVisualTime - self.engine.currentTime
	else
		dt = (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime) - self.engine.currentTime
	end
	
	return
		dataHead.x
		+ dataHead.fx * self.noteSkin:getVisualTimeRate() * dt
		+ dataBody.ox * self.noteSkin:getNoteWidth(self, "Head")
end

LongGraphicalNote.getHeadY = function(self)
	local data = self.noteSkin.data[self.id]["Head"]
	return
		data.y
		+ data.fy * self.noteSkin:getVisualTimeRate()
			* ((self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime) - self.engine.currentTime)
		+ data.oy * self.noteSkin:getNoteHeight(self, "Head")
end
LongGraphicalNote.getTailY = function(self)
	local dataHead = self.noteSkin.data[self.id]["Head"]
	local dataTail = self.noteSkin.data[self.id]["Tail"]
	return
		dataHead.y
		+ dataHead.fy * self.noteSkin:getVisualTimeRate()
			* (self.endNoteData.timePoint.currentVisualTime - self.engine.currentTime)
		+ dataTail.oy * self.noteSkin:getNoteHeight(self, "Tail")
end
LongGraphicalNote.getBodyY = function(self)
	local dataHead = self.noteSkin.data[self.id]["Head"]
	local dataBody = self.noteSkin.data[self.id]["Body"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	local dt
	if dataHead.fy * visualTimeRate <= 0 then
		dt = self.endNoteData.timePoint.currentVisualTime - self.engine.currentTime
	else
		dt = (self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime) - self.engine.currentTime
	end
	
	return
		dataHead.y
		+ dataHead.fy * self.noteSkin:getVisualTimeRate() * dt
		+ dataBody.oy * self.noteSkin:getNoteHeight(self, "Head")
end

LongGraphicalNote.getHeadScaleX = function(self)
	return self.noteSkin:getNoteWidth(self, "Head") / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Head"):getWidth())
end
LongGraphicalNote.getTailScaleX = function(self)
	return self.noteSkin:getNoteWidth(self, "Tail") / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Tail"):getWidth())
end
LongGraphicalNote.getBodyScaleX = function(self)
	local data = self.noteSkin.data[self.id]["Body"]
	local visualTimeRateSign = self.noteSkin:getVisualTimeRateSign()
	return
		(
			math.max(
				self.noteSkin.data[self.id]["Head"].fx *
				(self:getTailX() - self:getHeadX()) *
				visualTimeRateSign,
				0
			)
			+ data.w
		) / self.noteSkin:getCS(self):x(self.noteSkin:getNoteImage(self, "Body"):getWidth())
end

LongGraphicalNote.getHeadScaleY = function(self)
	return self.noteSkin:getNoteHeight(self, "Head") / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Head"):getHeight())
end
LongGraphicalNote.getTailScaleY = function(self)
	return self.noteSkin:getNoteHeight(self, "Tail") / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Tail"):getHeight())
end
LongGraphicalNote.getBodyScaleY = function(self)
	local data = self.noteSkin.data[self.id]["Body"]
	local visualTimeRateSign = self.noteSkin:getVisualTimeRateSign()
	return
		math.abs(
			math.max(
				self.noteSkin.data[self.id]["Head"].fy *
				(self:getTailY() - self:getHeadY()) *
				visualTimeRateSign,
				0
			)
			+ data.h
		) / self.noteSkin:getCS(self):y(self.noteSkin:getNoteImage(self, "Body"):getHeight())
end

LongGraphicalNote.whereWillDraw = function(self)
	local longNoteHeadX = self:getHeadX()
	local longNoteHeadY = self:getHeadY()
	local longNoteTailX = self:getTailX()
	local longNoteTailY = self:getTailY()
	local longNoteHeadWidth = self.noteSkin:getNoteWidth(self, "Head")
	local longNoteHeadHeight = self.noteSkin:getNoteHeight(self, "Head")
	local longNoteTailWidth = self.noteSkin:getNoteWidth(self, "Tail")
	local longNoteTailHeight = self.noteSkin:getNoteHeight(self, "Tail")
	
	local cs = self.noteSkin:getCS(self)
	
	local allcs = self.noteSkin.allcs
	local x, y
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
	
	return x, y
end

LongGraphicalNote.willDraw = function(self)
	local x, y = self:whereWillDraw()
	return x == 0 and y == 0
end
LongGraphicalNote.willDrawBeforeStart = function(self)
	local x, y = self:whereWillDraw()
	local data = self.noteSkin.data[self.id]["Head"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	return data.fx * x * visualTimeRate < 0 or data.fy * y * visualTimeRate < 0
end
LongGraphicalNote.willDrawAfterEnd = function(self)
	local x, y = self:whereWillDraw()
	local data = self.noteSkin.data[self.id]["Head"]
	local visualTimeRate = self.noteSkin.visualTimeRate
	return data.fx * x * visualTimeRate > 0 or data.fy * y * visualTimeRate > 0
end

return LongGraphicalNote
