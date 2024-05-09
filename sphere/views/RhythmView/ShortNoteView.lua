local NoteView = require("sphere.views.RhythmView.NoteView")
local math_util = require("math_util")
local gfx_util = require("gfx_util")
local just = require("just")

---@class sphere.ShortNoteView: sphere.NoteView
---@operator call: sphere.ShortNoteView
local ShortNoteView = NoteView + {}

function ShortNoteView:draw()
	local headView = self:getNotePart("Head")
	local spriteBatch = headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(headView:getColor())
	spriteBatch:add(self:getDraw(headView:getQuad(), self:getTransformParams()))

	local hw = self:getNotePart("Head")
	local w, h = hw:getDimensions()

	local tf = gfx_util.transform(self:getTransformParams())

	-- (S*N)^(1)*M = N^-1*S^-1*M
	-- local x, y = tf:inverseTransformPoint(love.graphics.inverseTransformPoint(love.mouse.getPosition()))

	-- self.graphicalNote.over = math_util.belong(x, 0, w) and math_util.belong(y, 0, h)

	love.graphics.push()
	love.graphics.applyTransform(tf)
	self.graphicalNote.over = just.is_over(w, h)
	self.graphicalNote.selecting = just.is_selected(w, h)
	love.graphics.pop()
end

function ShortNoteView:drawSelected()
	local hw = self:getNotePart("Head")
	local w, h = hw:getDimensions()

	local tf = gfx_util.transform(self:getTransformParams())
	local x, y = tf:transformPoint(0, 0)
	local _w, _h = tf:transformPoint(w, h)

	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", x, y, _w - x, _h - y)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", x, y, _w - x, _h - y)
end

---@param chords table
---@param column number
function ShortNoteView:fillChords(chords, column)
	local startNote = self.graphicalNote.startNote
	local time = startNote.visualPoint.point.absoluteTime

	chords[time] = chords[time] or {}
	local chord = chords[time]
	chord[column] = chord[column] or {}
	table.insert(chord[column], startNote)
end

---@return boolean
function ShortNoteView:isVisible()
	local color = self:getNotePart("Head"):getColor()
	if not color then
		return false
	end
	return color[4] > 0
end

---@return number?...
function ShortNoteView:getTransformParams()
	local hw = self:getNotePart("Head")
	local w, h = hw:getDimensions()
	local nw, nh = hw:get("w"), hw:get("h")
	local sx = nw and nw / w or hw:get("sx") or 1
	local sy = nh and nh / h or hw:get("sy") or 1
	local ox = (hw:get("ox") or 0) * w
	local oy = (hw:get("oy") or 0) * h
	return
		hw:get("x"),
		hw:get("y"),
		hw:get("r") or 0,
		sx,
		sy,
		ox,
		oy
end

return ShortNoteView
