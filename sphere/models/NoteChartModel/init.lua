local Class = require("aqua.util.Class")
local json = require("json")
local CacheManager		= require("sphere.database.CacheManager")
local NoteChartFactory			= require("notechart.NoteChartFactory")

local NoteChartModel = Class:new()

NoteChartModel.path = "userdata/selected.json"

NoteChartModel.construct = function(self)
	self.selected = {1, 1}
end

NoteChartModel.load = function(self)
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.selected = json.decode(file:read("*all"))
		file:close()

		self.noteChartSetEntry = CacheManager:getNoteChartSetEntryById(self.selected[1])
		self.noteChartEntry = CacheManager:getNoteChartEntryById(self.selected[2])
	end
end

NoteChartModel.unload = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.selected))
	return file:close()
end

NoteChartModel.selectNoteChartSet = function(self, id)
	self.selected[1] = id
end


NoteChartModel.selectNoteChart = function(self, id)
	self.selected[2] = id
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
