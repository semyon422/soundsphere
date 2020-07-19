load = function()
	scoreTable[config.tableName] = {}
end

map = function(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
end

getPoint = function(event)
	local point

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if not event.currentTime then
			return
		end
		local deltaTime = (event.currentTime - event.noteTime) / math.abs(event.timeRate)
		if newState == "passed" then
			point = {
				map(event.currentTime, event.minTime, event.maxTime, 0, 1),
				map(deltaTime, -config.scale, config.scale, 0, 1)
			}
		elseif newState == "missed" then
		end
	elseif event.noteType == "LongScoreNote" then
		if not event.currentTime then
			return
		end
		local deltaTime = (event.currentTime - event.noteStartTime) / math.abs(event.timeRate)
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				point = {
					map(event.currentTime, event.minTime, event.maxTime, 0, 1),
					map(deltaTime, -config.scale, config.scale, 0, 1)
				}
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

	return point
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local hits = scoreTable[config.tableName]
	hits[#hits + 1] = getPoint(event)
end
