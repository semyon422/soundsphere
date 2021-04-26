local Class = require("aqua.util.Class")
local NoteChartFactory			= require("notechart.NoteChartFactory")

local NoteChartModel = Class:new()

NoteChartModel.load = function(self)
	local config = self.configModel:getConfig("select")

	local cacheManager = self.cacheModel.cacheManager

	self.noteChartSetEntry = cacheManager:getNoteChartSetEntryById(config.noteChartSetEntryId)
	if not self.noteChartSetEntry then
		return
	end

	self.noteChartEntry = cacheManager:getNoteChartEntryById(config.noteChartEntryId)
	if not self.noteChartEntry then
		return
	end

	self.noteChartDataEntry = cacheManager:getNoteChartDataEntryById(config.noteChartDataEntryId)
		or cacheManager:getEmptyNoteChartDataEntry(self.noteChartEntry.path)
	self.scoreEntry = self.scoreModel.scoreManager:getScoreEntryById(config.scoreEntryId)
end

NoteChartModel.getFileInfo = function(self)
	if self.noteChartEntry then
		return love.filesystem.getInfo(self.noteChartEntry.path)
	end
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
