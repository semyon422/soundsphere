local Class = require("Class")
local NoteChartFactory			= require("notechart.NoteChartFactory")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local NoteChartModel = Class:new()

NoteChartModel.load = function(self)
	local config = self.game.configModel.configs.select

	self.noteChartSetEntry = CacheDatabase:selectNoteChartSetEntryById(config.noteChartSetEntryId)
	if not self.noteChartSetEntry then
		self.noteChartEntry = nil
		self.noteChartDataEntry = nil
		self.scoreEntry = nil
		return
	end

	self.noteChartEntry = CacheDatabase:selectNoteChartEntryById(config.noteChartEntryId)
	if not self.noteChartEntry then
		self.noteChartDataEntry = nil
		self.scoreEntry = nil
		return
	end

	self.noteChartDataEntry = CacheDatabase:selectNoteChartDataEntryById(config.noteChartDataEntryId)
	self.scoreEntry = self.game.scoreModel:getScoreEntryById(config.scoreEntryId)
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
