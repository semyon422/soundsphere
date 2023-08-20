local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

---@class sphere.ShortGraphicalNote: sphere.GraphicalNote
---@operator call: sphere.ShortGraphicalNote
local ShortGraphicalNote = GraphicalNote + {}

function ShortGraphicalNote:update()
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
	startTimeState.scaledAbsoluteDeltaTime = startTimeState.absoluteDeltaTime * self.graphicEngine:getVisualTimeRate()
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()
end

---@return number
function ShortGraphicalNote:whereWillDraw()
	return self:where(self.startTimeState.scaledVisualDeltaTime)
end

return ShortGraphicalNote
