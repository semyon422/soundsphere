load = function()
	scoreTable.score = 0
end

local maxScore = 1000000
local scale = 3.6
local unit = 1/60

local noteCount
getNoteCount = function(event)
	if noteCount then
		return noteCount
	end

	noteCount = 0
	noteCount = noteCount + (event.scoreNotesCount["ShortScoreNote"] or 0)
	noteCount = noteCount + (event.scoreNotesCount["LongScoreNote"] or 0)

	return noteCount
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	if math.abs(event.timeRate) == 0 then
		return
	end

	scoreTable.score = scoreTable.accuracy * 1000 * (scoreTable.hitcount + scoreTable.misscount) / scoreTable.hitcount / math.abs(event.timeRate)
end

