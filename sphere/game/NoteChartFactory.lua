local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")

local NoteChartFactory = {}

local patterns = {
	"%.osu$", "%.bms$", "%.bme$", "%.bml$", "%.ojn$"
}

NoteChartFactory.isNoteChart = function(self, path)
	for i = 1, #patterns do
		if path:find(patterns[i]) then
			return true
		end
	end
end

NoteChartFactory.getNoteChart = function(self, path)
	local noteChartImporter
	local noteChart = NoteChart:new()
	local chartIndex
	
	if path:find("%.osu$") then
		noteChartImporter = osu.NoteChartImporter:new()
	elseif path:find("%.bm.$") then
		noteChartImporter = bms.NoteChartImporter:new()
	elseif path:find("%.ojn/.$") then
		noteChartImporter = o2jam.NoteChartImporter:new()
		chartIndex = tonumber(path:sub(-1, -1))
		path = path:match("^(.+)/.$")
	end
	
	local file = love.filesystem.newFile(path)
	file:open("r")
	
	noteChartImporter.noteChart = noteChart
	noteChartImporter.chartIndex = chartIndex
	noteChartImporter:import(file:read())
	
	return noteChart
end

return NoteChartFactory
