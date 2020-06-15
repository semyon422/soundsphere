local timegatesLT0, timegatesMT0

local sortTimegates = function(a, b)
	return a.time < b.time
end

load = function()
	scoreTable.timegate = ""
	scoreTable.timegates = {}
	timegatesLT0, timegatesMT0 = {}, {}

	for _, data in ipairs(config.timegates) do
		if data.time < 0 then
			timegatesLT0[#timegatesLT0 + 1] = data
			data.time = - data.time
		elseif data.time > 0 then
			timegatesMT0[#timegatesMT0 + 1] = data
		end
	end

	table.sort(timegatesLT0, sortTimegates)
	table.sort(timegatesMT0, sortTimegates)
end

local increase = function(deltaTime)
	local timegates = deltaTime < 0 and timegatesLT0 or timegatesMT0
	deltaTime = math.abs(deltaTime)

	for i, data in ipairs(timegates) do
		if deltaTime <= data.time then
			for _, name in ipairs(data.names) do
				scoreTable.timegates[name] = (scoreTable.timegates[name] or 0) + 1
			end
			scoreTable.timegate = data.names[1]
			break
		end
	end
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		local deltaTime = (event.currentTime - event.noteTime) / math.abs(event.timeRate)
		if newState == "passed" then
			increase(deltaTime)
		elseif newState == "missed" then
			increase(deltaTime)
		end
	elseif event.noteType == "LongScoreNote" then
		local deltaTime = (event.currentTime - event.noteStartTime) / math.abs(event.timeRate)
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				increase(deltaTime)
			elseif newState == "startMissed" then
				increase(deltaTime)
			elseif newState == "startMissedPressed" then
				increase(deltaTime)
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
