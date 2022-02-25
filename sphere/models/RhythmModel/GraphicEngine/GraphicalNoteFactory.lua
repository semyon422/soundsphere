local FileManager			= require("sphere.filesystem.FileManager")
local ShortGraphicalNote	= require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local LongGraphicalNote		= require("sphere.models.RhythmModel.GraphicEngine.LongGraphicalNote")
local ImageNote				= require("sphere.models.RhythmModel.GraphicEngine.ImageNote")

local GraphicalNoteFactory = {}

GraphicalNoteFactory.getNote = function(self, noteData)
	local graphicalNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		graphicalNote.noteType = "ShortNote"
		return ShortGraphicalNote:new(graphicalNote)
	elseif noteData.noteType == "LongNoteStart" then
		graphicalNote.noteType = "LongNote"
		return LongGraphicalNote:new(graphicalNote)
	elseif noteData.noteType == "LaserNoteStart" then
		graphicalNote.noteType = "LongNote"
		return LongGraphicalNote:new(graphicalNote)
	elseif noteData.noteType == "LineNoteStart" then
		graphicalNote.noteType = "LongNote"
		return LongGraphicalNote:new(graphicalNote)
	elseif noteData.noteType == "SoundNote" then
		graphicalNote.noteType = "SoundNote"
		return ShortGraphicalNote:new(graphicalNote)
	elseif noteData.noteType == "ImageNote" then
		local fileType
		local images = noteData.images[1] and noteData.images[1][1]
		if images then
			fileType = FileManager:getType(images)
		end
		if fileType == "image" then
			graphicalNote.noteType = "ImageNote"
		elseif fileType == "video" then
			graphicalNote.noteType = "VideoNote"
		end
		return ImageNote:new(graphicalNote)
	end
end

return GraphicalNoteFactory
