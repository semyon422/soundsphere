local NoteView = require("sphere.views.RhythmView.NoteView")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local LightingNoteView = NoteView:new()

LightingNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")
end

LightingNoteView.draw = function(self)
	local spriteBatch = self.headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(self.headView:get("color"))
	spriteBatch:add(self:getDraw(self.headView:getQuad(), self:getTransformParams()))
end

LightingNoteView.getTransformParams = ShortNoteView.getTransformParams

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
