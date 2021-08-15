local NoteView = require("sphere.views.RhythmView.NoteView")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local LongNoteView = NoteView:new()

LongNoteView.construct = function(self)
	self.headView = NotePartView:new({}, self, "Head")
	self.bodyView = NotePartView:new({}, self, "Body")
	self.tailView = NotePartView:new({}, self, "Tail")
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

	headSpriteBatch:setColor(headView:get("color"))
	bodySpriteBatch:setColor(bodyView:get("color"))
	tailSpriteBatch:setColor(tailView:get("color"))

	local headQuad = headView:getQuad()
	local bodyQuad = bodyView:getQuad()
	local tailQuad = tailView:getQuad()

	if headQuad then
		headSpriteBatch:add(headQuad, self:getHeadTransformParams())
	else
		headSpriteBatch:add(self:getHeadTransformParams())
	end

	if bodyQuad then
		bodySpriteBatch:add(bodyQuad, self:getBodyTransformParams())
	else
		bodySpriteBatch:add(self:getBodyTransformParams())
	end

	if tailQuad then
		tailSpriteBatch:add(tailQuad, self:getTailTransformParams())
	else
		tailSpriteBatch:add(self:getTailTransformParams())
	end
end

LongNoteView.getHeadTransformParams = function(self)
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

LongNoteView.getTailTransformParams = function(self)
	local tw = self.tailView
	local ets = self.endTimeState
	local w, h = tw:getDimensions()
	return
		tw:get("x", ets),
		tw:get("y", ets),
		tw:get("r", ets),
		tw:get("w", ets) / w,
		tw:get("h", ets) / h,
		tw:get("ox", ets) * w,
		tw:get("oy", ets) * h
end

LongNoteView.getBodyTransformParams = function(self)
	local hw = self.headView
	local tw = self.tailView
	local bw = self.bodyView

	local sts = self.startTimeState
	local ets = self.endTimeState

	local dx = hw:get("x", sts) - tw:get("x", ets)
	local dy = hw:get("y", sts) - tw:get("y", ets)

	local btsx, btsy
	if dx >= 0 then btsx = ets
	else btsx = sts
	end
	if dy >= 0 then btsy = ets
	else btsy = sts
	end

	local w, h = bw:getDimensions()
	return
		bw:get("x", btsx),
		bw:get("y", btsy),
		0,
		(math.abs(dx) + bw:get("w", btsx)) / w,
		(math.abs(dy) + bw:get("h", btsy)) / h,
		bw:get("ox", btsx) * w,
		bw:get("oy", btsy) * h
end

return LongNoteView
