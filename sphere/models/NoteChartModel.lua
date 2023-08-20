local class = require("class")
local NoteChartFactory = require("notechart.NoteChartFactory")

---@class sphere.NoteChartModel
---@operator call: sphere.NoteChartModel
local NoteChartModel = class()

function NoteChartModel:load()
	local config = self.configModel.configs.select

	self.noteChartSetEntry = self.cacheModel.chartRepo:selectNoteChartSetEntryById(config.noteChartSetEntryId)
	if not self.noteChartSetEntry then
		self.noteChartEntry = nil
		self.noteChartDataEntry = nil
		return
	end

	self.noteChartEntry = self.cacheModel.chartRepo:selectNoteChartEntryById(config.noteChartEntryId)
	if not self.noteChartEntry then
		self.noteChartDataEntry = nil
		return
	end

	self.noteChartDataEntry = self.cacheModel.chartRepo:selectNoteChartDataEntryById(config.noteChartDataEntryId)
end

---@param settings table?
---@return ncdk.NoteChart?
function NoteChartModel:loadNoteChart(settings)
	local noteChartEntry = self.noteChartEntry
	local noteChartDataEntry = self.noteChartDataEntry

	if not noteChartEntry then
		return
	end

	local info = love.filesystem.getInfo(noteChartEntry.path)
	if not info then
		return
	end

	local file = love.filesystem.newFile(noteChartEntry.path)
	file:open("r")
	local content = file:read()
	file:close()

	local status, noteCharts = NoteChartFactory:getNoteCharts(
		noteChartEntry.path,
		content,
		noteChartDataEntry.index,
		settings
	)
	if not status then
		error(noteCharts)
	end

	self.noteChart = noteCharts[1]

	return self.noteChart
end

return NoteChartModel
