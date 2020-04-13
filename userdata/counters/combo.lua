local score

load = function(...)
	score = ...
	score.combo = 0
	score.maxcombo = 0
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if newState == "passed" then
			score.combo = score.combo + 1
			score.maxcombo = math.max(score.maxcombo, score.combo)
		elseif newState == "missed" then
			score.combo = 0
		end
	elseif event.noteType == "LongScoreNote" then
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				score.combo = score.combo + 1
				score.maxcombo = math.max(score.maxcombo, score.combo)
			elseif newState == "startMissed" then
				score.combo = 0
			elseif newState == "startMissedPressed" then
				score.combo = 0
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
				score.combo = 0
			elseif newState == "endMissed" then
				score.combo = 0
			elseif newState == "endPassed" then
			end
		elseif oldState == "startMissedPressed" then
			if newState == "endMissedPassed" then
			elseif newState == "startMissed" then
				score.combo = 0
			elseif newState == "endMissed" then
				score.combo = 0
			end
		elseif oldState == "startMissed" then
			if newState == "startMissedPressed" then
			elseif newState == "endMissed" then
				score.combo = 0
			end
		end
	end
end

