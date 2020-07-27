local Class = require("aqua.util.Class")
local json = require("json")
local CacheManager		= require("sphere.database.CacheManager")
local NoteChartFactory			= require("notechart.NoteChartFactory")


local NoteChartModel = Class:new()

NoteChartModel.path = "userdata/selectedChart.json"

NoteChartModel.construct = function(self)
	self.selectedChart = {1, 1}
end

NoteChartModel.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.selectedChart = json.decode(file:read("*all"))
		file:close()

		self.noteChartSetEntry = CacheManager:getNoteChartSetEntryById(self.selectedChart[1])
		self.noteChartEntry = CacheManager:getNoteChartEntryById(self.selectedChart[2])
	end
end

NoteChartModel.getNoteChart = function(self)
	local noteChartEntry = self.noteChartEntry

	local file = love.filesystem.newFile(noteChartEntry.path)
	file:open("r")
	local content = file:read()
	file:close()

	local status, noteCharts = NoteChartFactory:getNoteCharts(
		noteChartEntry.path,
		content,
		noteChartEntry.index
	)
	if not status then
		error(noteCharts)
	end
	return noteCharts[1]
end

return NoteChartModel
