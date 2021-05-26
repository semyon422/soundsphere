local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
end

ShortGraphicalNote.update = function(self)
	self:computeVisualTime()
	self:computeTimeState()

	return self:tryNext()
end

ShortGraphicalNote.computeVisualTime = function(self)
	return self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

ShortGraphicalNote.computeTimeState = function(self)
	self.timeState = self.timeState or {}
	local timeState = self.timeState

	local currentTime = self.graphicEngine.currentTime + self.graphicEngine:getVisualOffset()

	timeState.currentTime = currentTime
	timeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	timeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime

	timeState.absoluteDeltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	timeState.visualDeltaTime = currentTime - self.startNoteData.timePoint.currentVisualTime
	timeState.scaledVisualDeltaTime = timeState.visualDeltaTime * self.noteSkin:getVisualTimeRate()
end

ShortGraphicalNote.reload = function(self)
end

ShortGraphicalNote.whereWillDraw = function(self)
	return self.noteSkin:whereWillDraw(self, "Head", self.timeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
