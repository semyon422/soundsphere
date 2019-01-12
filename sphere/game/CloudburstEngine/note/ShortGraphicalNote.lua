local Drawable = require("aqua.graphics.Drawable")
local GraphicalNote = require("sphere.game.CloudburstEngine.note.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
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
		self.drawable.y = self:getY()
		self.drawable.x = self:getX()
		self.drawable:reload()
		return self:updateColor(self.drawable.color, self:getColor())
	end
end

ShortGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.currentVisualTime
		= (self.startNoteData.zeroClearVisualTime - self.noteDrawer.currentClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint:getAbsoluteTime()
end

ShortGraphicalNote.activate = function(self)
	self.drawable = Drawable:new({
		cs = self:getCS(),
		x = self:getX(),
		y = self:getY(),
		sx = self:getScaleX(),
		sy = self:getScaleY(),
		drawable = self:getDrawable(),
		layer = self:getLayer(),
		color = {255, 255, 255, 255}
	})
	self.drawable:reload()
	self.container:add(self.drawable)
	
	self:updateColor(self.drawable.color, self:getColor())
	
	self.activated = true
end

ShortGraphicalNote.deactivate = function(self)
	self.container:remove(self.drawable)
	self.activated = false
end

ShortGraphicalNote.getColor = function(self)
	return self.noteSkin:getShortNoteColor(self)
end

ShortGraphicalNote.getLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Head")
end

ShortGraphicalNote.getDrawable = function(self)
	return self.noteSkin:getNoteDrawable(self, "Head")
end

ShortGraphicalNote.getX = function(self)
	return self.noteSkin:getShortNoteX(self)
end

ShortGraphicalNote.getY = function(self)
	return self.noteSkin:getShortNoteY(self)
end

ShortGraphicalNote.getScaleX = function(self)
	return self.noteSkin:getNoteScaleX(self, "Head")
end

ShortGraphicalNote.getScaleY = function(self)
	return self.noteSkin:getNoteScaleY(self, "Head")
end

ShortGraphicalNote.willDraw = function(self)
	return self.noteSkin:willShortNoteDraw(self)
end

ShortGraphicalNote.willDrawBeforeStart = function(self)
	return self.noteSkin:willShortNoteDrawBeforeStart(self)
end

ShortGraphicalNote.willDrawAfterEnd = function(self)
	return self.noteSkin:willShortNoteDrawAfterEnd(self)
end

return ShortGraphicalNote
