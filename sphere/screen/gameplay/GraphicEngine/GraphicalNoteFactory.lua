local ShortGraphicalNote	= require("sphere.screen.gameplay.GraphicEngine.ShortGraphicalNote")
local LongGraphicalNote		= require("sphere.screen.gameplay.GraphicEngine.LongGraphicalNote")
local ImageNote				= require("sphere.screen.gameplay.GraphicEngine.ImageNote")
local VideoNote				= require("sphere.screen.gameplay.GraphicEngine.VideoNote")

local GraphicalNoteFactory = {}

GraphicalNoteFactory.getNote = function(self, noteData)
	if noteData.noteType == "ShortNote" then
		return ShortGraphicalNote:new({
			startNoteData = noteData,
			-- inputModeString = inputModeString,
			noteType = "ShortNote"
		})
	elseif noteData.noteType == "LongNoteStart" then
		return LongGraphicalNote:new({
			startNoteData = noteData,
			endNoteData = noteData.endNoteData,
			-- inputModeString = inputModeString,
			noteType = "LongNote"
		})
	elseif noteData.noteType == "LineNoteStart" then
		return LongGraphicalNote:new({
			startNoteData = noteData,
			endNoteData = noteData.endNoteData,
			-- inputModeString = inputModeString,
			noteType = "LongNote"
		})
	elseif noteData.noteType == "SoundNote" then
		return ShortGraphicalNote:new({
			startNoteData = noteData,
			noteType = "SoundNote"
		})
	elseif noteData.noteType == "ImageNote" then
		local fileType
		local images = noteData.images[1] and noteData.images[1][1]
		if images then
			fileType = FileManager:getType(images)
		end
		if fileType == "image" then
			return ImageNote:new({
				startNoteData = noteData,
				images = noteData.images,
				noteType = "ImageNote"
			})
		elseif fileType == "video" then
			return VideoNote:new({
				startNoteData = noteData,
				images = noteData.images,
				noteType = "VideoNote"
			})
		end
	end
end

return GraphicalNoteFactory
