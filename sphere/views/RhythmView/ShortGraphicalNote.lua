local GraphicalNote = require("sphere.views.RhythmView.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	self.timeState = self.graphicalNoteModel.timeState
	self.logicalState = self.graphicalNoteModel.logicalNote:getLastState()

	local drawable = self.drawable
	drawable.x = self:getX()
	drawable.y = self:getY()
	drawable.sx = self:getScaleX()
	drawable.sy = self:getScaleY()
	drawable.color = self:getColor()
	drawable:reload()
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
	return self.noteSkinImageView:getG(self, "Head", "color", self.timeState)
end

ShortGraphicalNote.getDrawable = function(self)
	return self.noteSkinImageView:getImageDrawable(self, "Head")
end

ShortGraphicalNote.getContainer = function(self)
	return self.noteSkinImageView:getImageContainer(self, "Head")
end

ShortGraphicalNote.getHeadWidth = function(self)
	return self.noteSkinImageView:getG(self, "Head", "w", self.timeState)
end

ShortGraphicalNote.getHeadHeight = function(self)
	return self.noteSkinImageView:getG(self, "Head", "h", self.timeState)
end

ShortGraphicalNote.getX = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "x", self.timeState)
		+ self.noteSkinImageView:getG(self, "Head", "w", self.timeState)
		* self.noteSkinImageView:getG(self, "Head", "ox", self.timeState)
end

ShortGraphicalNote.getY = function(self)
	return
		  self.noteSkinImageView:getG(self, "Head", "y", self.timeState)
		+ self.noteSkinImageView:getG(self, "Head", "h", self.timeState)
		* self.noteSkinImageView:getG(self, "Head", "oy", self.timeState)
end

ShortGraphicalNote.getScaleX = function(self)
	return
		self:getHeadWidth() /
		self.noteSkinImageView:getCS(self):x(self.noteSkinImageView:getNoteImage(self, "Head"):getWidth())
end

ShortGraphicalNote.getScaleY = function(self)
	return
		self:getHeadHeight() /
		self.noteSkinImageView:getCS(self):y(self.noteSkinImageView:getNoteImage(self, "Head"):getHeight())
end

ShortGraphicalNote.whereWillDraw = function(self)
	return self.noteSkinImageView:whereWillDraw(self, "Head", self.timeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
