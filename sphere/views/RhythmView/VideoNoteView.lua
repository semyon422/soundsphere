local NoteView = require("sphere.views.RhythmView.NoteView")
local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local VideoNoteView = NoteView:new()

VideoNoteView.getTransformParams = ImageNoteView.getTransformParams

VideoNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")

	local images = self.startNoteData.images
	local path = NoteChartResourceLoader.aliases[images[1][1]]
	local resource = NoteChartResourceLoader.resources[path]

	if not resource then
		return
	end

	self.video = resource
	self.drawable = resource.image
end

VideoNoteView.draw = function(self)
	local video = self.video
	if not video then
		return
	end

	local timer = self.graphicalNote.timeEngine.timer

	video:play(timer:getTime())

	ImageNoteView.draw(self)
end

return VideoNoteView
