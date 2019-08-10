local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local ksm = require("ksm")
local quaver = require("quaver")
local sph = require("sph")
local md5 = require("md5")

local Log = require("aqua.util.Log")

local NoteChartFactory = {}

NoteChartFactory.log = Log:new()
NoteChartFactory.log.path = "userdata/chart.log"

local chartPatterns = {
	"%.osu$", "%.bm[sel]$", "%.pms$", "%.qua$", "%.ksh$", "%.sph$"
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

NoteChartFactory.readFile = function(self, path)
	local file = love.filesystem.newFile(path)
	file:open("r")
	local content = file:read()
	file:close()
	return content
end

NoteChartFactory.getNoteChartImporter = function(self, path)
	if path:find("%.osu$") then
		return osu.NoteChartImporter:new()
	elseif path:find("%.qua$") then
		return quaver.NoteChartImporter:new()
	elseif path:find("%.bm[sel]$") then
		return bms.NoteChartImporter:new()
	elseif path:find("%.pms$") then
		local noteChartImporter = bms.NoteChartImporter:new()
		noteChartImporter.pms = true
		return noteChartImporter
	elseif path:find("%.ksh$") then
		return ksm.NoteChartImporter:new()
	elseif path:find("%.ojn/.$") then
		local noteChartImporter = o2jam.NoteChartImporter:new()
		noteChartImporter.chartIndex = tonumber(path:sub(-1, -1))
		return noteChartImporter
	elseif path:find("%.sph$") then
		local noteChartImporter = sph.NoteChartImporter:new()
		noteChartImporter.path = path
		return noteChartImporter
	end
end

NoteChartFactory.getRealPath = function(self, path)
	if path:find("%.ojn/.$") then
		return path:match("^(.+)/.$")
	end
	return path
end

NoteChartFactory.deleteBOM = function(self, content)
	if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
		return content:sub(4, -1)
	end
	return content
end

NoteChartFactory.getNoteChart = function(self, path)
	self.log:write("get", path)
	
	local noteChart, hash
	local status, err = pcall(function()
		local noteChartImporter = self:getNoteChartImporter(path)
		local realPath = self:getRealPath(path)
		
		local rawContent = self:readFile(realPath)
		hash = md5.sumhexa(rawContent)
		local content = self:deleteBOM(rawContent:gsub("\r\n", "\n"))
		noteChart = noteChartImporter:import(content)
	end)
	
	if not status then
		self.log:write("error", err)
		return
	end
	
	return noteChart, hash
end

return NoteChartFactory
