local GraphicalNote	= require("sphere.screen.gameplay.CloudburstEngine.note.GraphicalNote")
local Rectangle		= require("aqua.graphics.Rectangle")

local LineGraphicalNote = GraphicalNote:new()

LineGraphicalNote.update = function(self)
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
		self.drawable.x = self:getX()
		self.drawable.y = self:getY()
		self.drawable:reload()
	end
end

LineGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	self.endNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

LineGraphicalNote.activate = function(self)
	self.drawable = self:getDrawable()
	self.drawable:reload()
	self.container = self:getContainer()
	self.container:add(self.drawable)
	
	self.activated = true
end

LineGraphicalNote.deactivate = function(self)
	self.container:remove(self.drawable)
	self.activated = false
end

LineGraphicalNote.reload = function(self)
	self.drawable:reload()
end

LineGraphicalNote.getLayer = function(self)
	return self.noteSkin:getNoteLayer(self, "Head")
end

LineGraphicalNote.getDrawable = function(self)
	return self.noteSkin:getRectangleDrawable(self, "Head")
end

LineGraphicalNote.getContainer = function(self)
	return self.noteSkin:getRectangleContainer(self, "Head")
end

LineGraphicalNote.getX = function(self)
	return self.noteSkin:getLineNoteX(self)
end
LineGraphicalNote.getY = function(self)
	return self.noteSkin:getLineNoteY(self)
end
LineGraphicalNote.getWidth = function(self)
	return self.noteSkin:getLineNoteScaledWidth(self)
end
LineGraphicalNote.getHeight = function(self)
	return self.noteSkin:getLineNoteScaledHeight(self)
end

LineGraphicalNote.willDraw = function(self)
	return self.noteSkin:willLineNoteDraw(self)
end
LineGraphicalNote.willDrawBeforeStart = function(self)
	return self.noteSkin:willLineNoteDrawBeforeStart(self)
end
LineGraphicalNote.willDrawAfterEnd = function(self)
	return self.noteSkin:willLineNoteDrawAfterEnd(self)
end

return LineGraphicalNote
