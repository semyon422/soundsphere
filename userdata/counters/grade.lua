local count, sum

load = function()
	scoreTable.grade = "?"

	count, sum = 0, 0
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local accuracy = scoreTable.accuracy
	for _, gradeConfig in ipairs(config.grades) do
		if not gradeConfig.time or accuracy <= gradeConfig.time * 1000 then
			scoreTable.grade = gradeConfig.name
			break
		end
	end
end
