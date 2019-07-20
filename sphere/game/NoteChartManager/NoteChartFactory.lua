local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local ksm = require("ksm")
local quaver = require("quaver")

local Log = require("aqua.util.Log")

local NoteChartFactory = {}

NoteChartFactory.log = Log:new()
NoteChartFactory.log.path = "userdata/chart.log"

local chartPatterns = {
	"%.osu$", "%.bm[sel]$", "%.qua$", "%.ksh$", "%.sph$"
}

local containerPatterns = {
	"%.ojn$"
}

NoteChartFactory.isNoteChart = function(self, path)
	for i = 1, #chartPatterns do
		if path:find(chartPatterns[i]) then
			return true
		end
	end
end

NoteChartFactory.isNoteChartContainer = function(self, path)
	for i = 1, #containerPatterns do
		if path:find(containerPatterns[i]) then
			return true
		end
	end
end

NoteChartFactory.splitList = function(self, chartPaths)
	local dict = {}
	for _, path in ipairs(chartPaths) do
		for i = 1, #chartPatterns do
			if path:find(chartPatterns[i]) then
				dict[i] = dict[i] or {}
				table.insert(dict[i], path)
			end
		end
	end
	
	local list = {}
	for _, data in pairs(dict) do
		list[#list + 1] = data
	end
	
	return list
end

NoteChartFactory.getNoteChart = function(self, path)
	self.log:write("get", path)
	
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
	
	self.log:write("status", status, err)
	
	return noteChart
end

return NoteChartFactory
