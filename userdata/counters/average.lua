local values

load = function()
	scoreTable[config.key] = 0
	values = {}
	local count = config.count or #values
	for i = 1, count do
		values[i] = 0
	end
end

add = function(dt)
	table.remove(values, 1)
	table.insert(values, dt)

	local sum = 0
	local count = config.count or #values
	for i = 1, count do
		sum = sum + values[i]
	end
	scoreTable[config.key] = sum / count * 1000
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		if not event.currentTime then
			return
		end
		local deltaTime = (event.currentTime - event.noteTime) / math.abs(event.timeRate)
		if newState == "passed" then
			add(deltaTime)
		elseif newState == "missed" then
		end
	elseif event.noteType == "LongScoreNote" then
		if not event.currentTime then
			return
		end
		local deltaTime = (event.currentTime - event.noteStartTime) / math.abs(event.timeRate)
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				add(deltaTime)
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
end