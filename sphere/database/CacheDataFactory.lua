local NoteChartFactory	= require("sphere.database.NoteChartFactory")

local json	= require("json")
local md5	= require("md5")
local utf8	= require("utf8")

local iconv = require("aqua.iconv")

local CacheDataFactory = {}

local charsets = {
	{"UTF-8", "SHIFT-JIS"},
	{"UTF-8", "CP932"},
	{"UTF-8", "EUC-KR"},
	{"UTF-8", "US-ASCII"},
	{"UTF-8", "CP1252"},
	{"UTF-8//IGNORE", "SHIFT-JIS"},
}

CacheDataFactory.init = function(self)
	local conversionDescriptors = {}
	self.conversionDescriptors = conversionDescriptors
	
	for i, tofrom in ipairs(charsets) do
		conversionDescriptors[i] = iconv:open(tofrom[1], tofrom[2])
	end
end

CacheDataFactory.splitList = function(self, chartPaths)
	local dict = {}
	for _, path in ipairs(chartPaths) do
		for i = 1, #self.formats do
			local pattern = self.formats[i][1]
			if path:find(pattern) then
				dict[pattern] = dict[pattern] or {}
				table.insert(dict[pattern], path)
			end
		end
	end
	
	local list = {}
	for _, data in pairs(dict) do
		list[#list + 1] = data
	end
	
	return list
end

CacheDataFactory.getCacheDatas = function(self, chartPaths)
	local formats = self.formats
	
	local cacheDatas = {}
	for _, paths in ipairs(self:splitList(chartPaths)) do
		local path = paths[1]
		for _, data in ipairs(formats) do
			local pattern = data[1]
			local getCacheDatas = data[2]
			if path:lower():find(pattern) then
				for _, cacheData in ipairs(getCacheDatas(self, paths)) do
					cacheDatas[#cacheDatas + 1] = cacheData
				end
			end
		end
	end
	
	return cacheDatas
end

local trimName = function(name)
	if name:find("%[.+%]") then
		return name:match("%[(.+)%]"), name:find("%[.+%]")
	elseif name:find("%(.+%)") then
		return name:match("%((.+)%)"), name:find("%(.+%)")
	elseif name:find("%-.+%-$") then
		return name:match("%-(.+)%-"), name:find("%-.+%-$")
	elseif name:find("\".+\"$") then
		return name:match("\"(.+)\""), name:find("\".+\"$")
	elseif name:find("〔.+〕$") then
		return name:match("〔(.+)〕"), name:find("〔.+〕$")
	else
		return name, #name + 1
	end
end

CacheDataFactory.processCacheDataNames = function(self, cacheDatas)
	local titleTable = {}
	local title = cacheDatas[1].title
	local name, bracketStart = trimName(title)
	
	local continue = false
	local byteOffset = 0
	local byteNext = 0
	for i = 1, bracketStart do
		byteOffset = utf8.offset(title, i)
		byteNext = utf8.offset(title, i + 1)
		if not byteOffset or not byteNext then
			break
		end
		local char = title:sub(byteOffset, byteNext - 1)
		if char and title:find(char, 1, true) == bracketStart then
			break
		end
		for j = 1, #cacheDatas do
			if char ~= cacheDatas[j].title:sub(byteOffset, byteNext - 1) then
				continue = true
				break
			elseif j == #cacheDatas then
				titleTable[#titleTable + 1] = char
			end
		end
		if continue then break end
	end
	
	local title = table.concat(titleTable):trim()
	for i = 1, #cacheDatas do
		if #title > 0 then
			cacheDatas[i].name = trimName(cacheDatas[i].title:sub(#title + 1, -1)):trim()
			cacheDatas[i].title = title
		else
			local name, bracketStart = trimName(cacheDatas[i].title)
			cacheDatas[i].name = name
			cacheDatas[i].title = cacheDatas[i].title
		end
	end
end

CacheDataFactory.processCacheDataNameSingle = function(self, cacheDatas)
	local title = cacheDatas[1].title
	local name, bracketStart = trimName(title)
	title = title:sub(1, bracketStart - 1)
	
	cacheDatas[1].name = name
	cacheDatas[1].title = title
end

local validate = require("aqua.utf8").validate
local fix = function(line)
	if not line then
		return ""
	elseif validate(line) == line then
		return line
	else
		local validLine
		for i, cd in ipairs(CacheDataFactory.conversionDescriptors) do
			validLine = cd:convert(line)
			if validLine then break end
		end
		validLine = validLine or "<conversion error>"
		return validate(validLine)
	end
end

local numberFields = {
	"level",
	"previewTime",
	"noteCount",
	"length",
	"bpm"
}

local stringFields = {
	"path",
	"hash",
	"title",
	"artist",
	"source",
	"tags",
	"name",
	"creator",
	"audioPath",
	"stagePath",
	"inputMode"
}

CacheDataFactory.fixCacheData = function(self, cacheData)
	for _, field in ipairs(numberFields) do
		local value = cacheData[field]
		if not value or not tonumber(value) then
			cacheData[field] = 0
		else
			cacheData[field] = tonumber(value)
		end
	end
	for _, field in ipairs(stringFields) do
		local value = cacheData[field]
		if not value then
			cacheData[field] = ""
		else
			cacheData[field] = fix(value)
		end
	end
end

CacheDataFactory.getBMS = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			local bms = noteChart.importer.bms
			local header = bms.header
			local cacheData = {
				path		= path,
				hash		= hash,
				title		= header["TITLE"],
				artist		= header["ARTIST"],
				source		= "BMS",
				tags		= "",
				name		= nil,
				level		= header["PLAYLEVEL"],
				creator		= "",
				audioPath	= "",
				stagePath	= header["STAGEFILE"],
				previewTime	= 0,
				noteCount	= noteChart:hashGet("noteCount"),
				length		= noteChart:hashGet("totalLength"),
				bpm			= bms.baseTempo or 0,
				inputMode	= noteChart.inputMode:getString()
			}
			
			cacheDatas[#cacheDatas + 1] = cacheData
		end
		io.write(".")
	end
	io.write("\n")
	
	if #cacheDatas > 0 then
		for _, cacheData in ipairs(cacheDatas) do
			self:fixCacheData(cacheData)
		end
		if #cacheDatas == 1 then
			self:processCacheDataNameSingle(cacheDatas)
		else
			self:processCacheDataNames(cacheDatas)
		end
	end
	
	return cacheDatas
end

CacheDataFactory.getOsu = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			local osu = noteChart.importer.osu
			local metadata = osu.metadata
			local cacheData = {
				path		= path,
				hash		= hash,
				title		= metadata["Title"],
				artist		= metadata["Artist"],
				source		= metadata["Source"],
				tags		= metadata["Tags"],
				name		= metadata["Version"],
				level		= 0,
				creator		= metadata["Creator"],
				audioPath	= metadata["AudioFilename"],
				stagePath	= osu.background,
				previewTime	= metadata["PreviewTime"] / 1000,
				noteCount	= noteChart:hashGet("noteCount"),
				length		= noteChart:hashGet("totalLength"),
				bpm			= noteChart.importer.primaryBPM,
				inputMode	= noteChart.inputMode:getString()
			}
			self:fixCacheData(cacheData)
			
			cacheDatas[#cacheDatas + 1] = cacheData
		end
		io.write(".")
	end
	io.write("\n")
	
	return cacheDatas
end

CacheDataFactory.getKSM = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			local importer = noteChart.importer
			local ksh = importer.ksh
			local options = ksh.options
			local cacheData = {
				path		= path,
				hash		= hash,
				title		= options["title"],
				artist		= options["artist"],
				source		= "KSM",
				tags		= "",
				name		= options["difficulty"],
				level		= options["level"],
				creator		= options["effect"],
				audioPath	= importer.audioFileName,
				stagePath	= options["jacket"],
				previewTime	= (options["plength"] or 0) / 1000,
				noteCount	= noteChart:hashGet("noteCount"),
				length		= noteChart:hashGet("totalLength"),
				bpm			= 0,
				inputMode	= noteChart.inputMode:getString()
			}
			self:fixCacheData(cacheData)
			
			cacheDatas[#cacheDatas + 1] = cacheData
		end
		io.write(".")
	end
	io.write("\n")
	
	return cacheDatas
end

CacheDataFactory.getQuaver = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			local qua = noteChart.importer.qua
			local cacheData = {
				path		= path,
				hash		= hash,
				title		= qua["Title"],
				artist		= qua["Artist"],
				source		= qua["Source"],
				tags		= qua["Tags"],
				name		= qua["DifficultyName"],
				level		= 0,
				creator		= qua["Creator"],
				audioPath	= qua["AudioFile"],
				stagePath	= qua["BackgroundFile"],
				previewTime	= (qua["SongPreviewTime"] or 0) / 1000,
				noteCount	= noteChart:hashGet("noteCount"),
				length		= noteChart:hashGet("totalLength"),
				bpm			= noteChart.importer.primaryBPM,
				inputMode	= noteChart.inputMode:getString()
			}
			
			cacheDatas[#cacheDatas + 1] = cacheData
		end
		io.write(".")
	end
	io.write("\n")
	
	return cacheDatas
end

local o2jamDifficultyNames = {"Easy", "Normal", "Hard"}
CacheDataFactory.getO2Jam = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(path)
		local ojn = noteChart.importer.ojn
		
		for i = 1, 3 do
			local cacheData = {
				path		= path .. "/" .. i,
				hash		= hash,
				title		= ojn.str_title,
				artist		= ojn.str_artist,
				source		= "o2jam",
				tags		= "",
				name		= o2jamDifficultyNames[i],
				level		= ojn.charts[i].level,
				creator		= ojn.str_noter,
				audioPath	= "",
				stagePath	= "",
				previewTime	= 0,
				noteCount	= ojn.charts[i].notes,
				length		= ojn.charts[i].duration,
				bpm			= ojn.bpm,
				inputMode	= "7key"
			}
			self:fixCacheData(cacheData)
			
			cacheDatas[#cacheDatas + 1] = cacheData
		end
		io.write(".")
	end
	io.write("\n")
	
	return cacheDatas
end

CacheDataFactory.getSphere = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		
		local file = love.filesystem.newFile(path)
		file:open("r")
		local content = file:read(file:getSize())
		local hash = md5.sumhexa(content)
		local data = json.decode(content)
		file:close()
		
		local cacheData = {
			path		= path,
			hash		= hash,
			title		= data.title,
			artist		= data.artist,
			source		= data.source,
			tags		= data.tags,
			name		= data.name,
			level		= data.level,
			creator		= data.creator,
			audioPath	= data.audioPath,
			stagePath	= data.stagePath,
			previewTime	= data.previewTime,
			noteCount	= data.noteCount,
			length		= data.length,
			bpm			= data.bpm,
			inputMode	= data.inputMode
		}
		self:fixCacheData(cacheData)
		
		cacheDatas[#cacheDatas + 1] = cacheData
		io.write(".")
	end
	io.write("\n")
	
	return cacheDatas
end

CacheDataFactory.formats = {
	{"%.osu", CacheDataFactory.getOsu},
	{"%.qua", CacheDataFactory.getQuaver},
	{"%.bm[sel]$", CacheDataFactory.getBMS},
	{"%.pms", CacheDataFactory.getBMS},
	{"%.ojn", CacheDataFactory.getO2Jam},
	{"%.ksh", CacheDataFactory.getKSM},
	{"%.sph", CacheDataFactory.getSphere}
}

return CacheDataFactory
