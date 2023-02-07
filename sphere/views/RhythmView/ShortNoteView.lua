local NoteView = require("sphere.views.RhythmView.NoteView")
local just = require("just")

local ShortNoteView = NoteView:new()

ShortNoteView.draw = function(self)
	local headView = self:getNotePart("Head")
	local spriteBatch = headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(headView:getColor())
	spriteBatch:add(self:getDraw(headView:getQuad(), self:getTransformParams()))

	love.graphics.push()
	local hw = self:getNotePart("Head")
	love.graphics.translate(hw:get("x"), hw:get("y"))

	local w, h = hw:get("w") or 0, hw:get("h") or 0
	love.graphics.translate(-(hw:get("ox") or 0) * w, -(hw:get("oy") or 0) * h)

	local noteData = self.graphicalNote.startNoteData
	local changed, active, hovered = just.button(noteData, just.is_over(w, h), 2)
	if changed then
		self.rhythmView:pressNote(noteData, self.graphicalNote.inputType, self.graphicalNote.inputIndex)
	end
	love.graphics.pop()
end

ShortNoteView.fillChords = function(self, chords, column)
	local startNoteData = self.graphicalNote.startNoteData

	local time = startNoteData.timePoint.absoluteTime
	chords[time] = chords[time] or {}
	local chord = chords[time]

	chord[column] = startNoteData.noteType
end

ShortNoteView.isVisible = function(self)
	local color = self:getNotePart("Head"):getColor()
	if not color then
		return
	end
	return color[4] > 0
end

ShortNoteView.getTransformParams = function(self)
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
