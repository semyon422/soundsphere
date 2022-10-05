local NoteView = require("sphere.views.RhythmView.NoteView")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local LongNoteView = NoteView:new()

LongNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")
	self.bodyView = self:newNotePartView("Body")
	self.tailView = self:newNotePartView("Tail")
end

LongNoteView.update = function(self)
	self.startTimeState = self.graphicalNote.startTimeState
	self.endTimeState = self.graphicalNote.endTimeState
	self.logicalState = self.graphicalNote.logicalNote.state

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
		bodySpriteBatch:setColor(bodyView:getColor())
		bodySpriteBatch:add(self:getDraw(bodyView:getQuad(), self:getBodyTransformParams()))
	end
	if tailSpriteBatch then
		tailSpriteBatch:setColor(tailView:getColor())
		tailSpriteBatch:add(self:getDraw(tailView:getQuad(), self:getTailTransformParams()))
	end
	if headSpriteBatch then
		headSpriteBatch:setColor(headView:getColor())
		headSpriteBatch:add(self:getDraw(headView:getQuad(), self:getHeadTransformParams()))
	end
end

LongNoteView.fillChords = function(self, chords, column)
	local startNoteData = self.startNoteData
	local endNoteData = self.endNoteData

	if startNoteData then
		local time = startNoteData.timePoint.absoluteTime
		chords[time] = chords[time] or {}
		local chord = chords[time]

		chord[column] = startNoteData.noteType
		self.startChord = chord
	end

	if endNoteData then
		local time = endNoteData.timePoint.absoluteTime
		chords[time] = chords[time] or {}
		local chord = chords[time]

		chord[column] = endNoteData.noteType
		self.endChord = chord
	end
end

LongNoteView.isVisible = ShortNoteView.isVisible

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
