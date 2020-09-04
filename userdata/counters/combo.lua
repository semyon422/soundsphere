load = function()
	scoreTable.misscount = 0
	scoreTable.hitcount = 0
	scoreTable.combo = 0
	scoreTable.maxcombo = 0
	scoreTable[config.tableName] = {}
end

map = function(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
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

getPoint = function(event)
	return {
		map(event.currentTime, event.minTime, event.maxTime, 0, 1),
		1 - scoreTable.combo / getNoteCount(event)
	}
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local combo = scoreTable.combo

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if newState == "passed" then
			scoreTable.hitcount = scoreTable.hitcount + 1
			scoreTable.combo = scoreTable.combo + 1
			scoreTable.maxcombo = math.max(scoreTable.maxcombo, scoreTable.combo)
		elseif newState == "missed" then
			scoreTable.combo = 0
			scoreTable.misscount = scoreTable.misscount + 1
		end
	elseif event.noteType == "LongScoreNote" then
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				scoreTable.combo = scoreTable.combo + 1
				scoreTable.maxcombo = math.max(scoreTable.maxcombo, scoreTable.combo)
			elseif newState == "startMissed" then
				scoreTable.combo = 0
				scoreTable.misscount = scoreTable.misscount + 1
			elseif newState == "startMissedPressed" then
				scoreTable.combo = 0
				scoreTable.misscount = scoreTable.misscount + 1
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
				scoreTable.combo = 0
			elseif newState == "endMissed" then
				scoreTable.combo = 0
			elseif newState == "endPassed" then
				scoreTable.hitcount = scoreTable.hitcount + 1
			end
		elseif oldState == "startMissedPressed" then
			if newState == "endMissedPassed" then
			elseif newState == "startMissed" then
				scoreTable.combo = 0
			elseif newState == "endMissed" then
				scoreTable.combo = 0
			end
		elseif oldState == "startMissed" then
			if newState == "startMissedPressed" then
			elseif newState == "endMissed" then
				scoreTable.combo = 0
			end
		end
	end

	if combo ~= scoreTable.combo then
		local hits = scoreTable[config.tableName]
		hits[#hits + 1] = getPoint(event)
	end
end

