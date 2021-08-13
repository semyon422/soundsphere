local NoteView = require("sphere.views.RhythmView.NoteView")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local ShortNoteView = NoteView:new()

ShortNoteView.construct = function(self)
	local headView = NotePartView:new()
	headView.noteView = self
	headView.name = "Head"
	self.headView = headView
end

ShortNoteView.update = function(self)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote:getLastState()
	self.headView.timeState = self.timeState
end

ShortNoteView.draw = function(self)
	local spriteBatch = self.headView:getSpriteBatch()
	spriteBatch:setColor(self.headView:get("color"))
	local quad = self.headView:getQuad()
	if quad then
		spriteBatch:add(quad, self:getTransformParams())
	else
		spriteBatch:add(self:getTransformParams())
	end
end

ShortNoteView.getTransformParams = function(self)
	-- x, y, r, sx, sy, ox, oy, kx, ky
	local hw = self.headView
	return
		hw:get("x") + hw:get("w") * hw:get("ox"),
		hw:get("y") + hw:get("h") * hw:get("oy"),
		0,
		hw:get("w") / hw:getWidth(),
		hw:get("h") / hw:getHeight()
end

return ShortNoteView
