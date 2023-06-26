local ImageNoteView		= require("sphere.views.RhythmView.ImageNoteView")

local VideoNoteView = ImageNoteView:new()

VideoNoteView.getVideo = function(self)
	local images = self.graphicalNote.startNoteData.images
	local resourceModel = self.graphicalNote.graphicEngine.rhythmModel.game.resourceModel
	local path = resourceModel.aliases[images[1][1]]
	return resourceModel.resources[path]
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
