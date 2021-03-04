load = function()
	scoreTable.enps = 0
	scoreTable.averageStrain = 0
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	if math.abs(event.timeRate) == 0 then
		return
	end

	scoreTable.enps = scoreTable.baseEnps * event.timeRate
	scoreTable.averageStrain = scoreTable.baseAverageStrain * event.timeRate
end

