local NoteView = require("sphere.views.RhythmView.NoteView")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local LongNoteView = NoteView:new({construct = false})

LongNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")
	self.bodyView = self:newNotePartView("Body")
	self.tailView = self:newNotePartView("Tail")
end

LongNoteView.update = function(self)
	self.startTimeState = self.graphicalNote.startTimeState
	self.endTimeState = self.graphicalNote.endTimeState
	self.logicalState = self.graphicalNote.logicalNote:getLastState()

	self.headView.timeState = self.startTimeState
	self.bodyView.timeState = self.startTimeState
	self.tailView.timeState = self.startTimeState
end

LongNoteView.draw = function(self)
	local headView = self.headView
	local bodyView = self.bodyView
	local tailView = self.tailView

	local headSpriteBatch = headView:getSpriteBatch()
	local bodySpriteBatch = bodyView:getSpriteBatch()
	local tailSpriteBatch = tailView:getSpriteBatch()

	if bodySpriteBatch then
		bodySpriteBatch:setColor(bodyView:get("color"))
		bodySpriteBatch:add(self:getDraw(bodyView:getQuad(), self:getBodyTransformParams()))
	end
	if tailSpriteBatch then
		tailSpriteBatch:setColor(tailView:get("color"))
		tailSpriteBatch:add(self:getDraw(tailView:getQuad(), self:getTailTransformParams()))
	end
	if headSpriteBatch then
		headSpriteBatch:setColor(headView:get("color"))
		headSpriteBatch:add(self:getDraw(headView:getQuad(), self:getHeadTransformParams()))
	end
end

LongNoteView.getHeadTransformParams = ShortNoteView.getTransformParams

LongNoteView.getTailTransformParams = function(self)
	local tw = self.tailView
	local ets = self.endTimeState
	local w, h = tw:getDimensions()
	local nw, nh = tw:get("w", ets), tw:get("h", ets)
	local sx = nw and nw / w or tw:get("sx", ets) or 1
	local sy = nh and nh / h or tw:get("sy", ets) or 1
	local ox = (tw:get("ox", ets) or 0) * w
	local oy = (tw:get("oy", ets) or 0) * h
	return
		tw:get("x", ets),
		tw:get("y", ets),
		tw:get("r", ets) or 0,
		sx,
		sy,
		ox,
		oy
end

LongNoteView.getBodyTransformParams = function(self)
	local hw = self.headView
	local tw = self.tailView
	local bw = self.bodyView

	local sts = self.startTimeState
	local ets = self.endTimeState

	local dx = hw:get("x", sts) - tw:get("x", ets)
	local dy = hw:get("y", sts) - tw:get("y", ets)

	local w, h = bw:getDimensions()
	local nw, nh = bw:get("w"), bw:get("h")
	local sx = nw and (dx + nw) / w or bw:get("sx") or 1
	local sy = nh and (dy + nh) / h or bw:get("sy") or 1
	local ox = (bw:get("ox") or 0) * w
	local oy = (bw:get("oy") or 0) * h
	return
		bw:get("x", ets),
		bw:get("y", ets),
		0,
		sx,
		sy,
		ox,
		oy
end

return LongNoteView
