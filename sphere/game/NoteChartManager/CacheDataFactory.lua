local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local json = require("json")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local quaver = require("quaver")
local ksm = require("ksm")
local utf8 = require("utf8")

local CacheDataFactory = {}

CacheDataFactory.getCacheDatas = function(self, chartPaths)
	local path = chartPaths[1]
	if path:find("%.osu$") then
		return self:getOsu(chartPaths)
	elseif path:find("%.qua$") then
		return self:getQuaver(chartPaths)
	elseif path:find("%.bm[sel]$") then
		return self:getBMS(chartPaths)
	elseif path:find("%.ojn$") then
		return self:getO2Jam(chartPaths)
	elseif path:find("%.ksh$") then
		return self:getKSM(chartPaths)
	elseif path:find("%.sph$") then
		return self:getSphere(chartPaths)
	end
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
			elseif j == #cacheDatas - 1 then
				titleTable[#titleTable + 1] = char
			end
		end
		if continue then break end
	end
	
	local title = table.concat(titleTable):trim()
	for i = 1, #cacheDatas do
		if not cacheDatas[i].name then
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
end
CacheDataFactory.processCacheDataNameSingle = function(self, cacheDatas)
	local title = cacheDatas[1].title
	local name, bracketStart = trimName(title)
	title = title:sub(1, bracketStart - 1)
	
	cacheDatas[1].name = name
	cacheDatas[1].title = title
end

local iconv = require("aqua.iconv").iconv
local validate = require("aqua.utf8").validate
local fix = function(line)
	if not line then
		return ""
	elseif validate(line) == line then
		return line
	else
		return
			iconv(line, "UTF-8", "SHIFT-JIS") or
			iconv(line, "UTF-8", "EUC-KR") or
			iconv(line, "UTF-8", "US-ASCII") or
			iconv(line, "UTF-8", "CP1252") or
			line
	end
end

CacheDataFactory.getBMS = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			cacheDatas[#cacheDatas + 1] = {
				path = path,
				hash = "",
				title = fix(noteChart:hashGet("TITLE")),
				artist = fix(noteChart:hashGet("ARTIST")),
				source = "BMS",
				tags = "",
				name = nil,
				level = tonumber(noteChart:hashGet("PLAYLEVEL")),
				creator = fix(noteChart:hashGet("ARTIST")),
				audioPath = "",
				stagePath = fix(noteChart:hashGet("STAGEFILE")),
				previewTime = 0,
				noteCount = noteChart:hashGet("noteCount"),
				length = noteChart:hashGet("totalLength"),
				bpm = 120,
				inputMode = noteChart.inputMode:getString()
			}
		end
	end
	
	if #cacheDatas > 0 then
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
		local noteChart = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			cacheDatas[#cacheDatas + 1] = {
				path = path,
				hash = "",
				title = fix(noteChart:hashGet("Title")),
				artist = fix(noteChart:hashGet("Artist")),
				source = fix(noteChart:hashGet("Source")),
				tags = fix(noteChart:hashGet("Tags")),
				name = fix(noteChart:hashGet("Version")),
				level = 0,
				creator = fix(noteChart:hashGet("Creator")),
				audioPath = fix(noteChart:hashGet("AudioFilename")),
				stagePath = fix(noteChart:hashGet("Background")),
				previewTime = noteChart:hashGet("PreviewTime") / 1000,
				noteCount = noteChart:hashGet("noteCount"),
				length = noteChart:hashGet("totalLength") / 1000,
				bpm = noteChart:hashGet("primaryBPM"),
				inputMode = noteChart.inputMode:getString()
			}
		end
	end
	
	return cacheDatas
end

CacheDataFactory.getKSM = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			cacheDatas[#cacheDatas + 1] = {
				path = path,
				hash = "",
				title = fix(noteChart:hashGet("title")),
				artist = fix(noteChart:hashGet("artist")),
				source = "KSM",
				tags = "",
				name = fix(noteChart:hashGet("difficulty")),
				level = fix(noteChart:hashGet("level")),
				creator = fix(noteChart:hashGet("effect")),
				audioPath = fix(noteChart:hashGet("audio")),
				stagePath = fix(noteChart:hashGet("jacket")),
				previewTime = (noteChart:hashGet("plength") or 0) / 1000,
				noteCount = noteChart:hashGet("noteCount"),
				length = noteChart:hashGet("totalLength") / 1000,
				bpm = 0,
				inputMode = noteChart.inputMode:getString()
			}
		end
	end
	
	return cacheDatas
end

CacheDataFactory.getQuaver = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local noteChart = NoteChartFactory:getNoteChart(path)
		
		if noteChart then
			cacheDatas[#cacheDatas + 1] = {
				path = path,
				hash = "",
				title = fix(noteChart:hashGet("Title") or ""),
				artist = fix(noteChart:hashGet("Artist") or ""),
				source = fix(noteChart:hashGet("Source") or ""),
				tags = fix(noteChart:hashGet("Tags") or ""),
				name = fix(noteChart:hashGet("DifficultyName") or ""),
				level = 0,
				creator = fix(noteChart:hashGet("Creator") or ""),
				audioPath = fix(noteChart:hashGet("AudioFile") or ""),
				stagePath = fix(noteChart:hashGet("BackgroundFile") or ""),
				previewTime = noteChart:hashGet("SongPreviewTime") / 1000,
				noteCount = noteChart:hashGet("noteCount"),
				length = noteChart:hashGet("totalLength") / 1000,
				bpm = noteChart:hashGet("primaryBPM"),
				inputMode = noteChart.inputMode:getString()
			}
		end
	end
	
	return cacheDatas
end

local o2jamDifficultyNames = {"Easy", "Normal", "Hard"}
CacheDataFactory.getO2Jam = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local file = love.filesystem.newFile(path)
		file:open("r")
		local ojn = o2jam.OJN:new(file:read(file:getSize()))
		file:close()
		
		for i = 1, 3 do
			cacheDatas[#cacheDatas + 1] = {
				path = path .. "/" .. i,
				hash = "",
				title = fix(ojn.str_title),
				artist = fix(ojn.str_artist),
				source = "o2jam",
				tags = "",
				name = o2jamDifficultyNames[i],
				level = ojn.charts[i].level,
				creator = fix(ojn.str_noter),
				audioPath = "",
				stagePath = "",
				previewTime = 0,
				noteCount = ojn.charts[i].notes,
				length = ojn.charts[i].duration,
				bpm = ojn.bpm,
				inputMode = "7key"
			}
		end
	end
	
	return cacheDatas
end

CacheDataFactory.getSphere = function(self, chartPaths)
	local cacheDatas = {}
	
	for i = 1, #chartPaths do
		local path = chartPaths[i]
		local file = love.filesystem.newFile(path)
		file:open("r")
		local data = json.decode(file:read(file:getSize()))
		file:close()
		
		cacheDatas[#cacheDatas + 1] = {
			path = path,
			hash = "",
			title = data.title,
			artist = data.artist,
			source = data.source,
			tags = data.tags,
			name = data.name,
			level = data.level,
			creator = data.creator,
			audioPath = data.audioPath,
			stagePath = data.stagePath,
			previewTime = data.previewTime,
			noteCount = data.noteCount,
			length = data.length,
			bpm = data.bpm,
			inputMode = data.inputMode
		}
	end
	
	return cacheDatas
end

return CacheDataFactory
