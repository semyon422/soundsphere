local NoteView = require("sphere.views.RhythmView.NoteView")

local ShortNoteView = NoteView:new()

ShortNoteView.update = function(self)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote:getLastState()
	self.headConfig = self.noteSkin:get(self, "Head", self.timeState)
end

ShortNoteView.draw = function(self)
	local spriteBatch = self.rhythmView:getSpriteBatch(self, "Head")
	spriteBatch:setColor(self:getColor())
	local quad = self.rhythmView:getQuad(self, "Head")
	if quad then
		spriteBatch:add(
			quad,
			self:getTransformParams()
		)
	else
		spriteBatch:add(
			self:getTransformParams()
		)
	end
end

ShortNoteView.getSpriteBatch = function(self)
	return self.rhythmView:getSpriteBatch(self, "Head")
end

ShortNoteView.getTransformParams = function(self)
	-- x, y, r, sx, sy, ox, oy, kx, ky
	return
		self:getX(),
		self:getY(),
		0,
		self:getScaleX(),
		self:getScaleY()
end

ShortNoteView.getColor = function(self)
	return self.noteSkin:get(self, "Head", "color", self.timeState)
end

ShortNoteView.getHeadWidth = function(self)
	return self.noteSkin:get(self, "Head", "w", self.timeState)
end

ShortNoteView.getHeadHeight = function(self)
	return self.noteSkin:get(self, "Head", "h", self.timeState)
end

ShortNoteView.getX = function(self)
	return
		self.noteSkin:get(self, "Head", "x", self.timeState) +
		self.noteSkin:get(self, "Head", "w", self.timeState) *
		self.noteSkin:get(self, "Head", "ox", self.timeState)
end

ShortNoteView.getY = function(self)
	return
		self.noteSkin:get(self, "Head", "y", self.timeState) +
		self.noteSkin:get(self, "Head", "h", self.timeState) *
		self.noteSkin:get(self, "Head", "oy", self.timeState)
	-- local head = get head
	-- head.timeState = self.timeState
	-- y = head:get("y")
end

ShortNoteView.getScaleX = function(self)
	return
		self:getHeadWidth() /
		self.rhythmView:getNoteImageWidth(self, "Head")
end

ShortNoteView.getScaleY = function(self)
	return
		self:getHeadHeight() /
		self.rhythmView:getNoteImageHeight(self, "Head")
end

return ShortNoteView
