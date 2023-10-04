local DifficultyModel = require("sphere.models.DifficultyModel")

local NoteChartFactory = require("notechart.NoteChartFactory")

local WebNoteChartController = {}

local function read_file(path)
	local file, err = io.open(path, "r")
	if not file then
		return nil, err
	end
	local content = file:read("*a")
	file:close()
	return content
end

function WebNoteChartController.getNoteCharts(notechart)
	local content, err = read_file(notechart.path)
	if not content then
		return nil, err
	end

	return NoteChartFactory:getNoteCharts(
		notechart.path .. "." .. notechart.extension,
		content
	)
end

function WebNoteChartController.getNoteChart(notechart)
	local content, err = read_file(notechart.path)
	if not content then
		return nil, err
	end

	return NoteChartFactory:getNoteChart(
		notechart.path .. "." .. notechart.extension,
		content,
		notechart.index
	)
end

function WebNoteChartController:POST()
	local noteCharts, err = WebNoteChartController.getNoteCharts(self.params.notechart)
	if not noteCharts then
		return {status = 500, json = {error = err}}
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
