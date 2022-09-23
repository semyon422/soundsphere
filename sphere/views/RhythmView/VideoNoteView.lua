local NoteView = require("sphere.views.RhythmView.NoteView")
local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")
local video			= require("aqua.video")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local VideoNoteView = NoteView:new({construct = false})

VideoNoteView.timeRate = 0

VideoNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")

	local images = self.startNoteData.images
	local path = NoteChartResourceLoader.aliases[images[1][1]]

	local vid = video.newVideo(path)

	if vid then
		vid:rewind()

		self.video = vid
		self.drawable = vid.image
	end
end

VideoNoteView.draw = ImageNoteView.draw
VideoNoteView.getTransformParams = ImageNoteView.getTransformParams

VideoNoteView.update = function(self, dt)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote.state
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState
	local timer = self.graphicalNote.timeEngine.timer

	local vid = self.video
	if vid then
		vid:seek(timer:getTime())
	end
end

return VideoNoteView
