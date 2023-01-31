local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ShortGraphicalNote = GraphicalNote:new()

ShortGraphicalNote.update = function(self)
	local timePoint = self.startNoteData.timePoint
	local visualTime = timePoint:getVisualTime(self.currentTimePoint)

	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.graphicEngine:getCurrentTime()

	startTimeState.currentTime = currentTime
	startTimeState.absoluteTime = timePoint.absoluteTime
	startTimeState.currentVisualTime = visualTime

	startTimeState.absoluteDeltaTime = currentTime - timePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (visualTime + self.graphicEngine:getVisualOffset())
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()
end

ShortGraphicalNote.whereWillDraw = function(self)
	return self:where(self.startTimeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
