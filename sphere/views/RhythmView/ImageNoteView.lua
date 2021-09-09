local image			= require("aqua.image")
local NoteView = require("sphere.views.RhythmView.NoteView")
local ShortNoteView = require("sphere.views.RhythmView.ShortNoteView")
local NotePartView = require("sphere.views.RhythmView.NotePartView")

local ImageNoteView = NoteView:new({construct = false})

ImageNoteView.construct = function(self)
	NoteView.construct(self)

	self.images = self.startNoteData.images
	self.headView = NotePartView:new({}, self, "Head")
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote:getLastState()
	self.headView.timeState = self.timeState

	local path = self.graphicEngine.localAliases[self.startNoteData.images[1][1]] or self.graphicEngine.globalAliases[self.startNoteData.images[1][1]]
	self.drawable = image.getImage(path)
end

ImageNoteView.draw = function(self)
	local drawable = self.drawable
	if not drawable then
		return
	end

	love.graphics.setColor(self.headView:get("color"))
	love.graphics.draw(drawable, self:getTransformParams())
end

ImageNoteView.getTransformParams = ShortNoteView.getTransformParams

return ImageNoteView
