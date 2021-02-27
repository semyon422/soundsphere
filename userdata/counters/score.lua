load = function()
	scoreTable.score = 0
	scoreTable.logscore = 0
	scoreTable.missFactor = 0
end

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

	scoreTable.missFactor = (scoreTable.hitcount + scoreTable.misscount) / scoreTable.hitcount

	scoreTable.score = scoreTable.accuracy * 1000 * scoreTable.missFactor / math.abs(event.timeRate)
	scoreTable.logscore = math.log(scoreTable.score / 1000) / math.log(2 ^ 0.1)
end

