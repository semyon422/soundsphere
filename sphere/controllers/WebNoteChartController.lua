local DifficultyModel = require("sphere.models.DifficultyModel")

local NoteChartFactory = require("notechart.NoteChartFactory")

local WebNoteChartController = {}

WebNoteChartController.getNoteChart = function(notechart)
	local file = io.open(notechart.path, "r")
	if not file then
		error("Notechart not found")
	end
	local content = file:read("*a")
	file:close()

	local status, noteCharts = NoteChartFactory:getNoteCharts(
		notechart.path .. "." .. notechart.extension,
		content,
		notechart.index
	)
	return noteCharts[1]
end

WebNoteChartController.POST = function(self)
	local noteChart = WebNoteChartController.getNoteChart(self.params.notechart)
	local noteChartDataEntry = noteChart.metaData:getTable()

	local difficulty, longNoteRatio = DifficultyModel:getDifficulty(noteChart)
	noteChartDataEntry.difficulty = difficulty

	return {json = {notechart = noteChartDataEntry}}
end


return WebNoteChartController
