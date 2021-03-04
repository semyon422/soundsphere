load = function()
	scoreTable.performance = 0
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	if math.abs(event.timeRate) == 0 then
		return
	end

	scoreTable.performance = scoreTable.baseEnps / scoreTable.score * 1e6
	scoreTable.logperformance = math.log(scoreTable.performance / 100) / math.log(2 ^ 0.1)
end

