local NoteView = require("sphere.views.RhythmView.NoteView")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local AnimationNoteView = NoteView:new()

AnimationNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")
end

AnimationNoteView.draw = function(self)
	local spriteBatch = self.headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(self.headView:get("color"))
	spriteBatch:add(self:getDraw(self.headView:getQuad(), self:getTransformParams()))
end

AnimationNoteView.getTransformParams = ShortNoteView.getTransformParams

AnimationNoteView.update = function(self)
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
end

return AnimationNoteView
