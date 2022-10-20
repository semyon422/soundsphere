local NoteView = require("sphere.views.RhythmView.NoteView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local ImageNoteView = NoteView:new()

ImageNoteView.getDrawable = function(self)
	local images = self.graphicalNote.startNoteData.images
	local path = NoteChartResourceLoader.aliases[images[1][1]]
	return NoteChartResourceLoader.resources[path]
end

ImageNoteView.draw = function(self)
	local drawable = self:getDrawable()
	if not drawable then
		return
	end

	love.graphics.setColor(self:getNotePart("Head"):getColor())
	love.graphics.draw(drawable, self:getTransformParams())
end

ImageNoteView.getTransformParams = function(self)
	local hw = self:getNotePart("Head")
	local w, h = self:getDrawable():getDimensions()
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

return ImageNoteView
