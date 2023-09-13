local DifficultyModel = require("sphere.models.DifficultyModel")

local NoteChartFactory = require("notechart.NoteChartFactory")

local WebNoteChartController = {}

WebNoteChartController.getNoteCharts = function(notechart)
	local file = io.open(notechart.path, "r")
	if not file then
		return
	end
	local content = file:read("*a")
	file:close()

	local ok, noteCharts = NoteChartFactory:getNoteCharts(
		notechart.path .. "." .. notechart.extension,
		content,
		notechart.index
	)
	return ok, noteCharts
end

function WebNoteChartController:POST()
	local ok, noteCharts = WebNoteChartController.getNoteCharts(self.params.notechart)
	if not ok then
		return {status = 500, json = {error = noteCharts}}
	end

	local noteChartDataEntries = {}
	for _, noteChart in ipairs(noteCharts) do
		local noteChartDataEntry = noteChart.metaData
		local difficulty, longNoteRatio, longNoteArea = DifficultyModel:getDifficulty(noteChart)
		noteChartDataEntry.difficulty = difficulty
		noteChartDataEntry.longNoteRatio = longNoteRatio
		noteChartDataEntry.longNoteArea = longNoteArea
		table.insert(noteChartDataEntries, noteChartDataEntry)
	end

	return {status = 200, json = {notecharts = noteChartDataEntries}}
end


return WebNoteChartController
