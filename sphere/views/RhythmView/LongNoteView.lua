local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")

local LongNoteView = ShortNoteView:new()

LongNoteView.draw = function(self)
	local headView = self:getNotePart("Head")
	local bodyView = self:getNotePart("Body")
	local tailView = self:getNotePart("Tail")

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
	local startNoteData = self.graphicalNote.startNoteData
	local endNoteData = self.graphicalNote.endNoteData

	if startNoteData then
		local time = startNoteData.timePoint.absoluteTime
		chords[time] = chords[time] or {}
		local chord = chords[time]

		chord[column] = startNoteData.noteType
	end

	if endNoteData then
		local time = endNoteData.timePoint.absoluteTime
		chords[time] = chords[time] or {}
		local chord = chords[time]

		chord[column] = endNoteData.noteType
	end
end

LongNoteView.getHeadTransformParams = LongNoteView.getTransformParams

LongNoteView.getTailTransformParams = function(self)
	local tw = self:getNotePart("Tail")
	local ets = self.graphicalNote.endTimeState
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
	local hw = self:getNotePart("Head")
	local tw = self:getNotePart("Tail")
	local bw = self:getNotePart("Body")

	local sts = self.graphicalNote.startTimeState
	local ets = self.graphicalNote.endTimeState

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
