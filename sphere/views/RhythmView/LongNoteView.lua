local NoteView = require("sphere.views.RhythmView.NoteView")

local LongNoteView = NoteView:new()

LongNoteView.update = function(self)
	-- self.startTimeState = self.graphicalNote.startTimeState
	-- self.endTimeState = self.graphicalNote.endTimeState
	-- self.logicalState = self.graphicalNote.logicalNote:getLastState()

	-- self.headDrawable.x = self:getHeadX()
	-- self.tailDrawable.x = self:getTailX()
	-- self.bodyDrawable.x = self:getBodyX()
	-- self.headDrawable.sx = self:getHeadScaleX()
	-- self.tailDrawable.sx = self:getTailScaleX()
	-- self.bodyDrawable.sx = self:getBodyScaleX()

	-- self.headDrawable.y = self:getHeadY()
	-- self.tailDrawable.y = self:getTailY()
	-- self.bodyDrawable.y = self:getBodyY()
	-- self.headDrawable.sy = self:getHeadScaleY()
	-- self.tailDrawable.sy = self:getTailScaleY()
	-- self.bodyDrawable.sy = self:getBodyScaleY()

	-- self.headDrawable:reload()
	-- self.tailDrawable:reload()
	-- self.bodyDrawable:reload()

	-- self.headDrawable.color = self:getHeadColor()
	-- self.tailDrawable.color = self:getTailColor()
	-- self.bodyDrawable.color = self:getBodyColor()
end

LongNoteView.draw = function(self)

end

LongNoteView.activate = function(self)
	-- self.headDrawable = self:getHeadDrawable()
	-- self.tailDrawable = self:getTailDrawable()
	-- self.bodyDrawable = self:getBodyDrawable()
	-- self.headDrawable:reload()
	-- self.tailDrawable:reload()
	-- self.bodyDrawable:reload()
	-- self.headContainer = self:getHeadContainer()
	-- self.tailContainer = self:getTailContainer()
	-- self.bodyContainer = self:getBodyContainer()
	-- self.headContainer:add(self.headDrawable)
	-- self.tailContainer:add(self.tailDrawable)
	-- self.bodyContainer:add(self.bodyDrawable)

	self.activated = true
end

LongNoteView.deactivate = function(self)
	-- self.headContainer:remove(self.headDrawable)
	-- self.tailContainer:remove(self.tailDrawable)
	-- self.bodyContainer:remove(self.bodyDrawable)
	self.activated = false
end

LongNoteView.reload = function(self)
	-- self.headDrawable.sx = self:getHeadScaleX()
	-- self.headDrawable.sy = self:getHeadScaleY()
	-- self.tailDrawable.sx = self:getTailScaleX()
	-- self.tailDrawable.sy = self:getTailScaleY()
	-- self.bodyDrawable.sx = self:getBodyScaleX()
	-- self.bodyDrawable.sy = self:getBodyScaleY()
	-- self.headDrawable:reload()
	-- self.tailDrawable:reload()
	-- self.bodyDrawable:reload()
end

LongNoteView.getHeadColor = function(self)
	return self.noteSkinImageView:getG(self, "Head", "color", self.startTimeState)
end

LongNoteView.getTailColor = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "color", self.startTimeState)
end

LongNoteView.getBodyColor = function(self)
	return self.noteSkinImageView:getG(self, "Body", "color", self.startTimeState)
end

LongNoteView.getHeadLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Head")
end

LongNoteView.getTailLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Tail")
end

LongNoteView.getBodyLayer = function(self)
	return self.noteSkinImageView:getNoteLayer(self, "Body")
end

LongNoteView.getHeadDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Head")
end

LongNoteView.getTailDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Tail")
end

LongNoteView.getBodyDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Body")
end

LongNoteView.getHeadContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Head")
end

LongNoteView.getTailContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Tail")
end

LongNoteView.getBodyContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Body")
end

LongNoteView.getHeadWidth = function(self)
	return self.noteSkinImageView:getG(self, "Head", "w", self.startTimeState)
end

LongNoteView.getTailHeight = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "h", self.startTimeState)
end

LongNoteView.getBodyWidth = function(self)
	return self.noteSkinImageView:getG(self, "Body", "w", self.startTimeState)
end

LongNoteView.getHeadHeight = function(self)
	return self.noteSkinImageView:getG(self, "Head", "h", self.startTimeState)
end

LongNoteView.getTailWidth = function(self)
	return self.noteSkinImageView:getG(self, "Tail", "w", self.startTimeState)
end

LongNoteView.getBodyHeight = function(self)
	return self.noteSkinImageView:getG(self, "Body", "h", self.startTimeState)
end

LongNoteView.getHeadX = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "x", self.startTimeState)
		+ self.noteSkinImageView:getG(self, "Head", "w", self.startTimeState)
		* self.noteSkinImageView:getG(self, "Head", "ox", self.startTimeState)
end

LongNoteView.getTailX = function(self)
	return
		  self.noteSkinImageView:getG(self, "Tail", "x", self.endTimeState)
		+ self.noteSkinImageView:getG(self, "Tail", "w", self.endTimeState)
		* self.noteSkinImageView:getG(self, "Tail", "ox", self.endTimeState)
end

LongNoteView.getBodyX = function(self)
	local dg = self:getHeadX() - self:getTailX()
	local timeState
	if dg >= 0 then
		timeState = self.endTimeState
	else
		timeState = self.startTimeState
	end
	return
		  self.noteSkinImageView:getG(self, "Body", "x", timeState)
		+ self.noteSkinImageView:getG(self, "Head", "w", timeState)
		* self.noteSkinImageView:getG(self, "Body", "ox", timeState)
end

LongNoteView.getHeadY = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "y", self.startTimeState)
		+ self.noteSkinImageView:getG(self, "Head", "h", self.startTimeState)
		* self.noteSkinImageView:getG(self, "Head", "oy", self.startTimeState)
end

LongNoteView.getTailY = function(self)
	return
		  self.noteSkinImageView:getG(self, "Tail", "y", self.endTimeState)
		+ self.noteSkinImageView:getG(self, "Tail", "h", self.endTimeState)
		* self.noteSkinImageView:getG(self, "Tail", "oy", self.endTimeState)
end

LongNoteView.getBodyY = function(self)
	local dg = self:getHeadY() - self:getTailY()
	local timeState
	if dg >= 0 then
		timeState = self.endTimeState
	else
		timeState = self.startTimeState
	end
	return
		  self.noteSkinImageView:getG(self, "Body", "y", timeState)
		+ self.noteSkinImageView:getG(self, "Head", "h", timeState)
		* self.noteSkinImageView:getG(self, "Body", "oy", timeState)
end

LongNoteView.getHeadScaleX = function(self)
	return self:getHeadWidth() / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Head"):getWidth())
end

LongNoteView.getTailScaleX = function(self)
	return self:getTailWidth() / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Tail"):getWidth())
end

LongNoteView.getBodyScaleX = function(self)
	return
		(
			math.abs(self:getHeadX() - self:getTailX())
			+ self.noteSkinImageView:getG(self, "Body", "w", self.startTimeState)
		) / self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Body"):getWidth())
end

LongNoteView.getHeadScaleY = function(self)
	return self:getHeadHeight() / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Head"):getHeight())
end

LongNoteView.getTailScaleY = function(self)
	return self:getTailHeight() / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Tail"):getHeight())
end

LongNoteView.getBodyScaleY = function(self)
	return
		(
			math.abs(self:getHeadY() - self:getTailY())
			+ self.noteSkinImageView:getG(self, "Body", "h", self.startTimeState)
		) / self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Body"):getHeight())
end

return LongNoteView
