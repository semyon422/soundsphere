local ScoreNote     	= require("sphere.models.RhythmModel.ScoreEngine.ScoreNote")
local ShortScoreNote	= require("sphere.models.RhythmModel.ScoreEngine.ShortScoreNote")
local LongScoreNote	    = require("sphere.models.RhythmModel.ScoreEngine.LongScoreNote")

local ScoreNoteFactory = {}

ScoreNoteFactory.getNote = function(self, noteData)
	local scoreNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		return ShortScoreNote:new(scoreNote)
	elseif noteData.noteType == "LongNoteStart" then
		return LongScoreNote:new(scoreNote)
	elseif noteData.noteType == "LaserNoteStart" then
		return LongScoreNote:new(scoreNote)
	else
		return ScoreNote:new(scoreNote)
	end
end

return ScoreNoteFactory
