local NoteChartFactory		= require("sphere.database.NoteChartFactory")
local NoteChartEntryFactory	= require("sphere.database.NoteChartEntryFactory")

local json	= require("json")
local md5	= require("md5")
local utf8	= require("utf8")

local iconv = require("aqua.iconv")

local NoteChartDataEntryFactory = {}

local charsets = {
	{"UTF-8", "SHIFT-JIS"},
	{"UTF-8", "CP932"},
	{"UTF-8", "EUC-KR"},
	{"UTF-8", "US-ASCII"},
	{"UTF-8", "CP1252"},
	{"UTF-8//IGNORE", "SHIFT-JIS"},
}

NoteChartDataEntryFactory.init = function(self)
	local conversionDescriptors = {}
	self.conversionDescriptors = conversionDescriptors
	
	for i, tofrom in ipairs(charsets) do
		conversionDescriptors[i] = iconv:open(tofrom[1], tofrom[2])
	end
end

NoteChartDataEntryFactory.splitList = NoteChartEntryFactory.splitList

NoteChartDataEntryFactory.getEntries = NoteChartEntryFactory.getEntries

local bracketFindPattern = "%s.+%s"
local bracketMatchPattern = "%s(.+)%s"
local brackets = {
	{"%[", "%]"},
	{"%(", "%)"},
	{"%-", "%-"},
	{"\"", "\""},
	{"〔", "〕"},
	{"‾", "‾"},
	{"~", "~"}
}

local trimName = function(name)
	for i = 1, #brackets do
		local lb, rb = brackets[i][1], brackets[i][2]
		if name:find(bracketFindPattern:format(lb, rb)) then
			return name:match(bracketMatchPattern:format(lb, rb)), name:find(bracketFindPattern:format(lb, rb))
		end
	end
	return name, #name + 1
end

NoteChartDataEntryFactory.processEntryNames = function(self, entries)
	local titleTable = {}
	local title = entries[1].title
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
		for j = 1, #entries do
			if char ~= entries[j].title:sub(byteOffset, byteNext - 1) then
				continue = true
				break
			elseif j == #entries then
				titleTable[#titleTable + 1] = char
			end
		end
		if continue then break end
	end
	
	local title = table.concat(titleTable):trim()
	for i = 1, #entries do
		if #title > 0 then
			entries[i].name = trimName(entries[i].title:sub(#title + 1, -1)):trim()
			entries[i].title = title
		else
			local name, bracketStart = trimName(entries[i].title)
			entries[i].name = name
			entries[i].title = entries[i].title
		end
	end
end

NoteChartDataEntryFactory.processEntryNameSingle = function(self, entries)
	local title = entries[1].title
	local name, bracketStart = trimName(title)
	title = title:sub(1, bracketStart - 1)
	
	entries[1].name = name
	entries[1].title = title
end

local validate = require("aqua.utf8").validate
local fix = function(line)
	if not line then
		return ""
	elseif validate(line) == line then
		return line
	else
		local validLine
		for i, cd in ipairs(NoteChartDataEntryFactory.conversionDescriptors) do
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
	"bpm",
	"difficultyRate"
}

local stringFields = {
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

NoteChartDataEntryFactory.fixEntry = function(self, entry)
	for _, field in ipairs(numberFields) do
		local value = entry[field]
		if not value or not tonumber(value) then
			entry[field] = 0
		else
			entry[field] = tonumber(value)
		end
	end
	for _, field in ipairs(stringFields) do
		local value = entry[field]
		if not value then
			entry[field] = ""
		else
			entry[field] = fix(value)
		end
	end
end

--[[
	fileDatas = {
		{
			path = "path/to/chart.bms",
			content = "...",
			hash = "..."
		}
	}
]]
NoteChartDataEntryFactory.getBMS = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		
		if noteChart then
			local bms = noteChart.importer.bms
			local header = bms.header
			local entry = {
				hash			= hash,
				title			= header["TITLE"],
				artist			= header["ARTIST"],
				source			= "BMS",
				tags			= "",
				name			= nil,
				level			= header["PLAYLEVEL"],
				creator			= "",
				audioPath		= "",
				stagePath		= header["STAGEFILE"],
				previewTime		= 0,
				noteCount		= noteChart:hashGet("noteCount"),
				length			= noteChart:hashGet("totalLength"),
				bpm				= bms.baseTempo or 0,
				inputMode		= noteChart.inputMode:getString(),
				difficultyRate	= 0
			}
			
			entries[#entries + 1] = entry
			fileData.noteChartDataEntry = entry
		end
		io.write(".")
	end
	io.write("\n")
	
	if #entries > 0 then
		for _, entry in ipairs(entries) do
			self:fixEntry(entry)
		end
		if #entries == 1 then
			self:processEntryNameSingle(entries)
		else
			self:processEntryNames(entries)
		end
	end
	
	return entries
end

NoteChartDataEntryFactory.getOsu = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		
		if noteChart then
			local osu = noteChart.importer.osu
			local metadata = osu.metadata
			local entry = {
				hash			= hash,
				title			= metadata["Title"],
				artist			= metadata["Artist"],
				source			= metadata["Source"],
				tags			= metadata["Tags"],
				name			= metadata["Version"],
				level			= 0,
				creator			= metadata["Creator"],
				audioPath		= metadata["AudioFilename"],
				stagePath		= osu.background,
				previewTime		= metadata["PreviewTime"] / 1000,
				noteCount		= noteChart:hashGet("noteCount"),
				length			= noteChart:hashGet("totalLength"),
				bpm				= noteChart.importer.primaryBPM,
				inputMode		= noteChart.inputMode:getString(),
				difficultyRate	= 0
			}
			self:fixEntry(entry)
			
			entries[#entries + 1] = entry
			fileData.noteChartDataEntry = entry
		end
		io.write(".")
	end
	io.write("\n")
	
	return entries
end

NoteChartDataEntryFactory.getKSM = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		
		if noteChart then
			local importer = noteChart.importer
			local ksh = importer.ksh
			local options = ksh.options
			local entry = {
				hash			= hash,
				title			= options["title"],
				artist			= options["artist"],
				source			= "KSM",
				tags			= "",
				name			= options["difficulty"],
				level			= options["level"],
				creator			= options["effect"],
				audioPath		= importer.audioFileName,
				stagePath		= options["jacket"],
				previewTime		= (options["plength"] or 0) / 1000,
				noteCount		= noteChart:hashGet("noteCount"),
				length			= noteChart:hashGet("totalLength"),
				bpm				= 0,
				inputMode		= noteChart.inputMode:getString(),
				difficultyRate	= 0
			}
			self:fixEntry(entry)
			
			entries[#entries + 1] = entry
			fileData.noteChartDataEntry = entry
		end
		io.write(".")
	end
	io.write("\n")
	
	return entries
end

NoteChartDataEntryFactory.getQuaver = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		
		if noteChart then
			local qua = noteChart.importer.qua
			local entry = {
				hash			= hash,
				title			= qua["Title"],
				artist			= qua["Artist"],
				source			= qua["Source"],
				tags			= qua["Tags"],
				name			= qua["DifficultyName"],
				level			= 0,
				creator			= qua["Creator"],
				audioPath		= qua["AudioFile"],
				stagePath		= qua["BackgroundFile"],
				previewTime		= (qua["SongPreviewTime"] or 0) / 1000,
				noteCount		= noteChart:hashGet("noteCount"),
				length			= noteChart:hashGet("totalLength"),
				bpm				= noteChart.importer.primaryBPM,
				inputMode		= noteChart.inputMode:getString(),
				difficultyRate	= 0
			}
			
			entries[#entries + 1] = entry
			fileData.noteChartDataEntry = entry
		end
		io.write(".")
	end
	io.write("\n")
	
	return entries
end

--[[
	fileDatas = {
		{
			path = "path/to/chart.ojn/1",
			content = "...",
			hash = "..."
		},
		{
			path = "path/to/chart.ojn/2",
			content = "...",
			hash = "..."
		},
		{
			path = "path/to/chart.ojn/3",
			content = "...",
			hash = "..."
		}
	}
]]
local o2jamDifficultyNames = {"Easy", "Normal", "Hard"}
NoteChartDataEntryFactory.getO2Jam = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		local ojn = noteChart.importer.ojn
		
		local entry = {
			hash			= hash,
			title			= ojn.str_title,
			artist			= ojn.str_artist,
			source			= "o2jam",
			tags			= "",
			name			= o2jamDifficultyNames[i],
			level			= ojn.charts[i].level,
			creator			= ojn.str_noter,
			audioPath		= "",
			stagePath		= "",
			previewTime		= 0,
			noteCount		= ojn.charts[i].notes,
			length			= ojn.charts[i].duration,
			bpm				= ojn.bpm,
			inputMode		= "7key",
			difficultyRate	= 0
		}
		self:fixEntry(entry)
		
		entries[#entries + 1] = entry
		fileData.noteChartDataEntry = entry

		io.write(".")
	end
	io.write("\n")
	
	return entries
end

NoteChartDataEntryFactory.getSphere = function(self, fileDatas)
	local entries = {}
	
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]
		-- local noteChart, hash = NoteChartFactory:getNoteChart(fileData.path, fileData.content, fileData.hash)
		
		local file = love.filesystem.newFile(fileData.path)
		file:open("r")
		local content = file:read(file:getSize())
		local hash = md5.sumhexa(content)
		local data = json.decode(content)
		file:close()
		
		local entry = {
			path			= path,
			hash			= hash,
			title			= data.title,
			artist			= data.artist,
			source			= data.source,
			tags			= data.tags,
			name			= data.name,
			level			= data.level,
			creator			= data.creator,
			audioPath		= data.audioPath,
			stagePath		= data.stagePath,
			previewTime		= data.previewTime,
			noteCount		= data.noteCount,
			length			= data.length,
			bpm				= data.bpm,
			inputMode		= data.inputMode,
			difficultyRate	= 0
		}
		self:fixEntry(entry)
		
		entries[#entries + 1] = entry
		io.write(".")
	end
	io.write("\n")
	
	return entries
end

NoteChartDataEntryFactory.formats = {
	{"%.osu$", NoteChartDataEntryFactory.getOsu},
	{"%.qua$", NoteChartDataEntryFactory.getQuaver},
	{"%.bm[sel]$", NoteChartDataEntryFactory.getBMS},
	{"%.pms$", NoteChartDataEntryFactory.getBMS},
	{"%.ojn$", NoteChartDataEntryFactory.getO2Jam},
	{"%.ksh$", NoteChartDataEntryFactory.getKSM},
	{"%.sph$", NoteChartDataEntryFactory.getSphere}
}

return NoteChartDataEntryFactory
