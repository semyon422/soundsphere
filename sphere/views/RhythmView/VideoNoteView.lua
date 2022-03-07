local NoteView = require("sphere.views.RhythmView.NoteView")
local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")
local video			= require("aqua.video")

local VideoNoteView = NoteView:new({construct = false})

VideoNoteView.timeRate = 0

VideoNoteView.construct = function(self)
	NoteView.construct(self)
	self.headView = self:newNotePartView("Head")

	local images = self.startNoteData.images
	local graphicEngine = self.graphicalNote.graphicEngine
	local path = graphicEngine.localAliases[images[1][1]] or graphicEngine.globalAliases[images[1][1]]

	local vid = video.new(path)
	local image

	if vid then
		vid:rewind()
		image = vid.image

		vid:setTimer(self.graphicalNote.timeEngine.timer)

		self.video = vid
		self.drawable = image
	end
end

VideoNoteView.draw = ImageNoteView.draw
VideoNoteView.getTransformParams = ImageNoteView.getTransformParams

VideoNoteView.update = function(self, dt)
	self.timeState = self.graphicalNote.timeState
	self.logicalState = self.graphicalNote.logicalNote.state
	self.headView.timeState = self.graphicalNote.startTimeState or self.graphicalNote.timeState

	local vid = self.video
	if vid then
		vid:update(dt)
	end
end

return VideoNoteView
