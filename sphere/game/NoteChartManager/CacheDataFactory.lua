local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local quaver = require("quaver")

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
	end
end

local trimName = function(name)
	if name:find("%[.+%]") then
		return name:match("%[(.+)%]"), name:find("%[.+%]")
	elseif name:find("%(.+%)") then
		return name:match("%((.+)%)"), name:find("%(.+%)")
	elseif name:find("%-.+%-$") then
		return name:match("%-(.+)%-"), name:find("%-.+%-$")
	else
		return name, #name + 1
	end
end
CacheDataFactory.processCacheDataNames = function(self, cacheDatas)
	local titleTable = {}
	local title = cacheDatas[1].title
	local name, bracketStart = trimName(title)
	
	local continue = false
	for i = 1, bracketStart - 1 do
		for j = 1, #cacheDatas - 1 do
			if cacheDatas[j].title:sub(i, i) ~= cacheDatas[j + 1].title:sub(i, i) then
				continue = true
				break
			elseif j == #cacheDatas - 1 then
				titleTable[#titleTable + 1] = cacheDatas[1].title:sub(i, i)
			end
		end
		if continue then break end
	end
	
	local title = table.concat(titleTable):trim()
	for i = 1, #cacheDatas do
		if not cacheDatas[i].name then
			cacheDatas[i].name = trimName(cacheDatas[i].title:sub(#title + 1, -1)):trim()
			cacheDatas[i].title = title
		end
	end
end

local iconv = require("iconv")
local validate = require("aqua.utf8").validate
local fix = function(line)
	if not line then
		return ""
	elseif validate(line) == line then
		return line
	else
		return iconv(line, "UTF-8", "SHIFT-JIS") or iconv(line, "UTF-8", "EUC-KR") or iconv(line, "UTF-8", "US-ASCII") or line
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
				container = 0,
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
		self:processCacheDataNames(cacheDatas)
		cacheDatas[#cacheDatas + 1] = {
			path = cacheDatas[1].path:match("^(.+)/.-"),
			container = 1,
			
			title = cacheDatas[1].title,
			artist = cacheDatas[1].artist,
			source = cacheDatas[1].source,
			tags = cacheDatas[1].tags,
			creator = cacheDatas[1].creator,
			audioPath = cacheDatas[1].audioPath,
			stagePath = cacheDatas[1].stagePath,
			previewTime = cacheDatas[1].previewTime
		}
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
				container = 0,
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
	
	if #cacheDatas > 0 then
		cacheDatas[#cacheDatas + 1] = {
			path = cacheDatas[1].path:match("^(.+)/.-"),
			container = 1,
			
			title = cacheDatas[1].title,
			artist = cacheDatas[1].artist,
			source = cacheDatas[1].source,
			tags = cacheDatas[1].tags,
			creator = cacheDatas[1].creator,
			audioPath = cacheDatas[1].audioPath,
			stagePath = cacheDatas[1].stagePath,
			previewTime = cacheDatas[1].previewTime
		}
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
				container = 0,
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
	
	if #cacheDatas > 0 then
		cacheDatas[#cacheDatas + 1] = {
			path = cacheDatas[1].path:match("^(.+)/.-"),
			container = 1,
			
			title = cacheDatas[1].title,
			artist = cacheDatas[1].artist,
			source = cacheDatas[1].source,
			tags = cacheDatas[1].tags,
			creator = cacheDatas[1].creator,
			audioPath = cacheDatas[1].audioPath,
			stagePath = cacheDatas[1].stagePath,
			previewTime = cacheDatas[1].previewTime
		}
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
				container = 0,
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
		
		local lastCacheData = cacheDatas[#cacheDatas]
		cacheDatas[#cacheDatas + 1] = {
			path = lastCacheData.path:match("^(.+)/.-"),
			container = 1,
			
			title = lastCacheData.title,
			artist = lastCacheData.artist,
			source = lastCacheData.source,
			tags = lastCacheData.tags,
			creator = lastCacheData.creator,
			audioPath = lastCacheData.audioPath,
			stagePath = lastCacheData.stagePath,
			previewTime = lastCacheData.previewTime
		}
	end
	
	if #cacheDatas > 0 then
		cacheDatas[#cacheDatas + 1] = {
			path = cacheDatas[1].path:match("^(.+)/.-/.-"),
			container = 2,
			title = cacheDatas[1].path:match("^.+/(.-)/.-/.-$"),
		}
	end
	
	return cacheDatas
end

return CacheDataFactory
