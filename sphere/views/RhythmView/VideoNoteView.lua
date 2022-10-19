local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local VideoNoteView = ImageNoteView:new()

VideoNoteView.getVideo = function(self)
	local images = self.graphicalNote.startNoteData.images
	local path = NoteChartResourceLoader.aliases[images[1][1]]
	return NoteChartResourceLoader.resources[path]
end

VideoNoteView.getDrawable = function(self)
	local video = self:getVideo()
	if not video then
		return
	end

	return video.image
end

VideoNoteView.draw = function(self)
	local video = self:getVideo()
	if not video then
		return
	end

	local timer = self.graphicalNote.timeEngine.timer
	video:play(timer:getTime())

	ImageNoteView.draw(self)
end

return VideoNoteView
