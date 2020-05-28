local count, sum

load = function()
	scoreTable.accuracy = 0

	count, sum = 0, 0
end

local increase = function(deltaTime, sumMul, countMul)
	sum = sum + sumMul * deltaTime ^ 2
	count = count + countMul
end

local update = function()
	scoreTable.accuracy = 1000 * math.sqrt(sum / count)
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		local deltaTime = (event.currentTime - event.noteTime) / math.abs(event.timeRate)
		if newState == "passed" then
			increase(deltaTime, 1, 1)
		elseif newState == "missed" then
		end
	elseif event.noteType == "LongScoreNote" then
		local deltaTime = (event.currentTime - event.noteStartTime) / math.abs(event.timeRate)
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				increase(deltaTime, 1, 1)
			elseif newState == "startMissed" then
			elseif newState == "startMissedPressed" then
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
			elseif newState == "endMissed" then
			elseif newState == "endPassed" then
			end
		elseif oldState == "startMissedPressed" then
			if newState == "endMissedPassed" then
			elseif newState == "startMissed" then
			elseif newState == "endMissed" then
			end
		elseif oldState == "startMissed" then
			if newState == "startMissedPressed" then
			elseif newState == "endMissed" then
			end
		end
	end
	update()
end

