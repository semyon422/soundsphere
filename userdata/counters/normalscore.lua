local normalscore = require("libchart.normalscore")

local ns

load = function()
	scoreTable.normalscore_mean = 0
	scoreTable.normalscore_accuracy = 0
	scoreTable.normalscore_score = 0
	scoreTable.normalscore_score_adjusted = 0
	scoreTable.normalscore_hit_count = 0
	scoreTable.normalscore_miss_count = 0
	scoreTable.normalscore_accuracy_sum = 0
	scoreTable.normalscore_mean_sum = 0
	ns = normalscore:new()
end

local increase = function(deltaTime, timeRate)
	ns:hit(deltaTime, config.hitTimingWindow)
	scoreTable.normalscore_mean = ns.mean
	scoreTable.normalscore_accuracy = ns.score * 1e3
	scoreTable.normalscore_score = ns.score * 1e6 / math.abs(timeRate)
	scoreTable.normalscore_score_adjusted = ns.score_adjusted * 1e6 / math.abs(timeRate)
	scoreTable.normalscore_hit_count = ns.hit_count
	scoreTable.normalscore_miss_count = ns.miss_count
	scoreTable.normalscore_accuracy_sum = ns.accuracy_sum
	scoreTable.normalscore_mean_sum = 0
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
		increase(deltaTime, event.timeRate)
		if newState == "passed" then
		elseif newState == "missed" then
		end
	elseif event.noteType == "LongScoreNote" then
		if not event.currentTime then
			return
		end
		local deltaTime = (event.currentTime - event.noteStartTime) / math.abs(event.timeRate)
		if oldState == "clear" then
			increase(deltaTime, event.timeRate)
			if newState == "startPassedPressed" then
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

