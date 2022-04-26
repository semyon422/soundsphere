local image			= require("aqua.image")
local transform = require("aqua.graphics.transform")
local NoteView = require("sphere.views.RhythmView.NoteView")

local ImageNoteView = NoteView:new({construct = false})

ImageNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")

	local images = self.startNoteData.images
	local path = self.graphicalNote.graphicEngine.aliases[images[1][1]]
	self.drawable = image.getImage(path)
end

ImageNoteView.update = function(self)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote.state
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
end

ImageNoteView.draw = function(self)
	local drawable = self.drawable
	if not drawable then
		return
	end

	local tf = transform(self.rhythmView.config.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(self.headView:getColor())
	love.graphics.draw(drawable, self:getTransformParams())
end

ImageNoteView.getTransformParams = function(self)
	local hw = self.headView
	local w, h = self.drawable:getDimensions()
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
