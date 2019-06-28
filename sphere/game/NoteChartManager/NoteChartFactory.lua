local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local ksm = require("ksm")
local quaver = require("quaver")

local NoteChartFactory = {}

local patterns = {
	"%.osu$", "%.bm[sel]$", "%.ojn$", "%.qua$", "%.ksh$", "%.sph$"
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
	elseif path:find("%.qua$") then
		noteChartImporter = quaver.NoteChartImporter:new()
	elseif path:find("%.bm[sel]$") then
		noteChartImporter = bms.NoteChartImporter:new()
	elseif path:find("%.ksh$") then
		noteChartImporter = ksm.NoteChartImporter:new()
	elseif path:find("%.ojn/.$") then
		noteChartImporter = o2jam.NoteChartImporter:new()
		chartIndex = tonumber(path:sub(-1, -1))
		path = path:match("^(.+)/.$")
	elseif path:find("%.sph$") then
		local directoryPath, fileName = path:match("^(.+)/(.-)%.sph$")
		return dofile(directoryPath .. "/" .. fileName .. ".lua")(directoryPath)
	end
	
	local file = love.filesystem.newFile(path)
	file:open("r")
	
	noteChartImporter.noteChart = noteChart
	noteChartImporter.chartIndex = chartIndex
	
	local status, err = pcall(function()
		local content = file:read():gsub("\r\n", "\n")
		if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
			content = content:sub(4, -1)
		end
		return noteChartImporter:import(content)
	end)
	
	if not status then
		return print(err)
	end
	
	return noteChart
end

return NoteChartFactory
