local ShortLogicalNote	= require("sphere.screen.gameplay.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

LogicalNoteFactory.getNote = function(self, noteData)
	if noteData.noteType == "ShortNote" then
		return ShortLogicalNote:new({
			noteData = noteData,
			noteType = "ShortNote"
		})
	elseif noteData.noteType == "LongNoteStart" then
		return LongLogicalNote:new({
			noteData = noteData,
			noteType = "LongNote"
		})
	else
		return ShortLogicalNote:new({
			noteData = noteData,
			noteType = "ShortNote",
			autoplay = true
		})
	end
end

return LogicalNoteFactory
