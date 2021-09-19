local transform = require("aqua.graphics.transform")
local NoteView = require("sphere.views.RhythmView.NoteView")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local LightingNoteView = NoteView:new()

LightingNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = NotePartView:new({}, self, "Head")
end

LightingNoteView.draw = function(self)
	local spriteBatch = self.headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(self.headView:get("color"))
	spriteBatch:add(self:getDraw(self.headView:getQuad(), self:getTransformParams()))
end

LightingNoteView.getTransformParams = function(self)
	local hw = self.headView
	local w, h = hw:getDimensions()
	return
		hw:get("x"),
		hw:get("y"),
		hw:get("r"),
		hw:get("w") / w,
		hw:get("h") / h,
		hw:get("ox") * w,
		hw:get("oy") * h
end

LightingNoteView.update = function(self)
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
end

return LightingNoteView
