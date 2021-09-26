local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local LightingNoteView = ShortNoteView:new()

LightingNoteView.update = function(self)
	local timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
	self.headView.timeState = timeState
	local logicalState = self.graphicalNote.logicalNote:getLastState()
	if
		not self.startTime and (
			logicalState == "passed" or
			logicalState == "startPassedPressed" or
			logicalState == "startMissedPressed"
		)
	then
		self.startTime = timeState.currentTime
	end
	if
		self.startTime and
		logicalState ~= "passed" and
		logicalState ~= "startPassedPressed" and
		logicalState ~= "startMissedPressed"
	then
		self.startTime = nil
	end
end

return LightingNoteView
