load = function()
	scoreTable.combo = 0
	scoreTable.maxcombo = 0
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if newState == "passed" then
			scoreTable.combo = scoreTable.combo + 1
			scoreTable.maxcombo = math.max(scoreTable.maxcombo, scoreTable.combo)
		elseif newState == "missed" then
			scoreTable.combo = 0
		end
	elseif event.noteType == "LongScoreNote" then
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				scoreTable.combo = scoreTable.combo + 1
				scoreTable.maxcombo = math.max(scoreTable.maxcombo, scoreTable.combo)
			elseif newState == "startMissed" then
				scoreTable.combo = 0
			elseif newState == "startMissedPressed" then
				scoreTable.combo = 0
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
				scoreTable.combo = 0
			elseif newState == "endMissed" then
				scoreTable.combo = 0
			elseif newState == "endPassed" then
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
end

