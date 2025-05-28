local ImageNoteView = require("sphere.views.RhythmView.ImageNoteView")

---@class sphere.VideoNoteView: sphere.ImageNoteView
---@operator call: sphere.VideoNoteView
local VideoNoteView = ImageNoteView + {}

---@return any?
function VideoNoteView:getVideo()
	local images = self.graphicalNote.startNote.data.images
	return self.resourceModel:getResource(images[1] and images[1][1])
end

---@return love.Image?
function VideoNoteView:getDrawable()
	local video = self:getVideo()
	if not video then
		return
	end

	return video.image
end

function VideoNoteView:draw()
	local video = self:getVideo()
	if not video then
		return
	end

	local currentTime = self.graphicalNote.graphicEngine:getCurrentTime()
	video:play(currentTime - self.graphicalNote.startNote:getTime())

	ImageNoteView.draw(self)
end

return VideoNoteView
