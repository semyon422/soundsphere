CloudburstEngine.MeasureLine = createClass(CloudburstEngine.ShortGraphicalNote)
local MeasureLine = CloudburstEngine.MeasureLine

MeasureLine.getColour = function(self)
	return self.engine.noteSkin:getShortNoteColour(self)
end

MeasureLine.getLayer = function(self)
	return self.engine.noteSkin:getShortNoteLayer(self)
end

MeasureLine.getDrawable = function(self)
	return self.engine.noteSkin:getShortNoteDrawable(self)
end

MeasureLine.getX = function(self)
	return self.engine.noteSkin:getShortNoteX(self)
end

MeasureLine.getY = function(self)
	return self.engine.noteSkin:getShortNoteY(self)
end

MeasureLine.getScaleX = function(self)
	return self.engine.noteSkin:getShortNoteScaleX(self)
end

MeasureLine.getScaleY = function(self)
	return self.engine.noteSkin:getShortNoteScaleY(self)
end

MeasureLine.willDraw = function(self)
	return self.engine.noteSkin:willShortNoteDraw(self)
end

MeasureLine.willDrawBeforeStart = function(self)
	return self.engine.noteSkin:willShortNoteDrawBeforeStart(self)
end

MeasureLine.willDrawAfterEnd = function(self)
	return self.engine.noteSkin:willShortNoteDrawAfterEnd(self)
end
