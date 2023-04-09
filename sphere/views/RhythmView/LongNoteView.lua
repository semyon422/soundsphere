local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")
local gfx_util = require("gfx_util")
local just = require("just")

local LongNoteView = ShortNoteView:new()

LongNoteView.draw = function(self)
	local headView = self:getNotePart("Head")
	local bodyView = self:getNotePart("Body")
	local tailView = self:getNotePart("Tail")

	local headSpriteBatch = headView:getSpriteBatch()
	local bodySpriteBatch = bodyView:getSpriteBatch()
	local tailSpriteBatch = tailView:getSpriteBatch()

	self.bodyQuad = self.bodyQuad or love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	if bodySpriteBatch then
		bodySpriteBatch:setColor(bodyView:getColor())
		bodySpriteBatch:add(self.bodyQuad, self:getBodyTransformParams())
	end
	if tailSpriteBatch then
		tailSpriteBatch:setColor(tailView:getColor())
		tailSpriteBatch:add(self:getDraw(tailView:getQuad(), self:getTailTransformParams()))
	end
	if headSpriteBatch then
		headSpriteBatch:setColor(headView:getColor())
		headSpriteBatch:add(self:getDraw(headView:getQuad(), self:getHeadTransformParams()))
	end

	local hw = self:getNotePart("Head")
	local tw = self:getNotePart("Tail")

	local note = self.graphicalNote

	local tf = gfx_util.transform(self:getHeadTransformParams())
	local w, h = hw:getDimensions()
	love.graphics.push()
	love.graphics.applyTransform(tf)
	note.headOver = just.is_over(w, h)
	note.headSelecting = just.is_selected(w, h)
	love.graphics.pop()

	local tf = gfx_util.transform(self:getTailTransformParams())
	local w, h = tw:getDimensions()
	love.graphics.push()
	love.graphics.applyTransform(tf)
	note.tailOver = just.is_over(w, h)
	note.tailSelecting = just.is_selected(w, h)
	love.graphics.pop()

	local tf = gfx_util.transform(self:getBodyTransformParams())
	local _, _, w, h = self.bodyQuad:getViewport()
	love.graphics.push()
	love.graphics.applyTransform(tf)
	note.bodyOver = just.is_over(w, h)
	note.bodySelecting = just.is_selected(w, h)
	love.graphics.pop()

	self.graphicalNote.over = note.headOver or note.tailOver or note.bodyOver
	self.graphicalNote.selecting = note.headSelecting or note.tailSelecting or note.bodySelecting
end

LongNoteView.drawSelected = function(self)
	local hw = self:getNotePart("Head")
	local w, h = hw:getDimensions()

	local tf = gfx_util.transform(self:getTransformParams())
	local x, y = tf:transformPoint(0, 0)
	local _w, _h = tf:transformPoint(w, h)

	local tw = self:getNotePart("Tail")
	local w, h = tw:getDimensions()

	local tf = gfx_util.transform(self:getTailTransformParams())
	local x1, y1 = tf:transformPoint(0, 0)
	local _w1, _h1 = tf:transformPoint(w, h)

	local ymin = math.min(y, _h, y1, _h1)
	local ymax = math.max(y, _h, y1, _h1)

	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", x, ymin, _w - x, ymax - ymin)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", x, ymin, _w - x, ymax - ymin)
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

	local sx = nw and nw / w or bw:get("sx") or 1
	-- local sy = nh and nh / h or bw:get("sy") or 1
	local sy = 1 / 1.6

	self.bodyQuad:setViewport(0, 0, w, dy / sy, w, h)

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
