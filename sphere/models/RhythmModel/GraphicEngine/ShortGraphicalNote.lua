local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.currentTimePoint)

	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.timeEngine.currentVisualTime

	startTimeState.currentTime = currentTime
	startTimeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	startTimeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime

	startTimeState.absoluteDeltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (self.startNoteData.timePoint.currentVisualTime + self.timeEngine.visualOffset)
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()
end

ShortGraphicalNote.whereWillDraw = function(self)
	return self:where(self.startTimeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
