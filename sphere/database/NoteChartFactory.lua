local Log		= require("aqua.util.Log")
local md5		= require("md5")
local NoteChart	= require("ncdk.NoteChart")

local bms		= require("bms")
local ksm		= require("ksm")
local o2jam		= require("o2jam")
local osu		= require("osu")
local quaver	= require("quaver")
local sph		= require("sph")

local mime		= require("mime")
local zlib		= require("zlib")

local NoteChartFactory = {}

local chartPatterns = {
	"%.osu$", "%.bm[sel]$", "%.pms$", "%.qua$", "%.ksh$", "%.sph$"
}

local containerPatterns = {
	"%.ojn$"
}

NoteChartFactory.init = function(self)
	self.log = Log:new()
	self.log.path = "userdata/chart.log"
end

NoteChartFactory.isTextFile = function(self, path)
	return self:isNoteChart(path)
end

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
	elseif path:find("%.ojn$") or path:find("%.ojn/.$") then
		local noteChartImporter = o2jam.NoteChartImporter:new()
		noteChartImporter.chartIndex = tonumber(path:sub(-1, -1)) or 1
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

NoteChartFactory.getNoteChart = function(self, path, rawContent, hash)
	local noteChart, hash
	local status, err = xpcall(function()
		local noteChartImporter = self:getNoteChartImporter(path)
		local realPath = self:getRealPath(path)
		
		rawContent = rawContent or self:readFile(realPath)
		hash = hash or md5.sumhexa(rawContent)
		
		local content
		if self:isTextFile(realPath) then
			content = self:deleteBOM(rawContent:gsub("\r\n", "\n"))
		else
			content = rawContent
		end
		
		noteChart = noteChartImporter:import(content)
	end, debug.traceback)
	
	if not status then
		self.log:write("get", path)
		self.log:write("b64",  ("[[%s]]"):format(mime.b64(zlib.compress(rawContent))))
		self.log:write("error", err)
		return
	end
	
	return noteChart, hash
end

return NoteChartFactory
