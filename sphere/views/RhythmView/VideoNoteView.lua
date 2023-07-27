local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")

local VideoNoteView = ImageNoteView:new()

VideoNoteView.getVideo = function(self)
	local images = self.graphicalNote.startNoteData.images
	local resourceModel = self.graphicalNote.graphicEngine.rhythmModel.resourceModel
	return resourceModel:getResource(images[1][1])
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

	local currentTime = self.graphicalNote.graphicEngine:getCurrentTime()
	video:play(currentTime - self.graphicalNote.startNoteData.timePoint.absoluteTime)

	ImageNoteView.draw(self)
end

return VideoNoteView
