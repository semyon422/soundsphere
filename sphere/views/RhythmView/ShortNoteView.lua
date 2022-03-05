local NoteView = require("sphere.views.RhythmView.NoteView")

local ShortNoteView = NoteView:new({construct = false})

ShortNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")
end

ShortNoteView.update = function(self)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote.state
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
end

ShortNoteView.draw = function(self)
	local spriteBatch = self.headView:getSpriteBatch()
	if not spriteBatch then
		return
	end
	spriteBatch:setColor(self.headView:getColor())
	spriteBatch:add(self:getDraw(self.headView:getQuad(), self:getTransformParams()))
end

ShortNoteView.fillChords = function(self, chords, column)
	local startNoteData = self.startNoteData

	local time = startNoteData.timePoint.absoluteTime
	chords[time] = chords[time] or {}
	local chord = chords[time]

	chord[column] = startNoteData.noteType
	self.startChord = chord
end

ShortNoteView.isVisible = function(self)
	local color = self.headView:getColor()
	if not color then
		return
	end
	return color[4] > 0
end

ShortNoteView.getTransformParams = function(self)
	local hw = self.headView
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
