local DifficultyModel = require("sphere.models.DifficultyModel")

local NoteChartFactory = require("notechart.NoteChartFactory")

local WebNoteChartController = {}

WebNoteChartController.getNoteCharts = function(notechart)
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
	return noteCharts
end

WebNoteChartController.POST = function(self)
	local noteCharts = WebNoteChartController.getNoteCharts(self.params.notechart)

	local noteChartDataEntries = {}
	for _, noteChart in ipairs(noteCharts) do
		local noteChartDataEntry = noteChart.metaData:getTable()
		local difficulty, longNoteRatio = DifficultyModel:getDifficulty(noteChart)
		noteChartDataEntry.difficulty = difficulty
		table.insert(noteChartDataEntries, noteChartDataEntry)
	end

	return {json = {notecharts = noteChartDataEntries}}
end


return WebNoteChartController
