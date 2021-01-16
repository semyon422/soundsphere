local Class = require("aqua.util.Class")
local NoteChartFactory			= require("notechart.NoteChartFactory")

local NoteChartModel = Class:new()

NoteChartModel.select = function(self)
	local config = self.configModel:getConfig("select")

	self.noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(config.noteChartSetEntryId)
	self.noteChartEntry = self.cacheModel.cacheManager:getNoteChartEntryById(config.noteChartEntryId)
	self.noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntryById(config.noteChartDataEntryId)
		or self.cacheModel.cacheManager:getEmptyNoteChartDataEntry(self.noteChartEntry.path)
	self.scoreEntry = self.scoreModel.scoreManager:getScoreEntryById(config.scoreEntryId)
end

NoteChartModel.loadNoteChart = function(self, settings)
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

NoteChartModel.unloadNoteChart = function(self)
	self.noteChart = nil
end

return NoteChartModel
