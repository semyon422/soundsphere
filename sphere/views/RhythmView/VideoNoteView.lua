local NoteView = require("sphere.views.RhythmView.NoteView")
local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local VideoNoteView = NoteView:new({construct = false})

VideoNoteView.draw = ImageNoteView.draw
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

	resource:rewind()
end

VideoNoteView.update = function(self, dt)
	local video = self.video
	if not video then
		return
	end

	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote.state
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
	local timer = self.graphicalNote.timeEngine.timer

	video:play(timer:getTime())
end

return VideoNoteView
