local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local isNoteChart = function(path) return NoteChartFactory:isNoteChart(path) end
local getNoteChart = function(path) return NoteChartFactory:getNoteChart(path) end

local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")
local quaver = require("quaver")

local CacheDataFactory = {}

CacheDataFactory.getCacheDatasForPath = function(self, path)
	if path:find("%.osu$") then
		return self:getOsu(path)
	elseif path:find("%.qua$") then print(123)
		return self:getQuaver(path)
	elseif path:find("%.bm[sel]$") then
		return self:getBMS(path)
	elseif path:find("%.ojn$") then
		return self:getO2Jam(path)
	end
end

CacheDataFactory.getCacheDatas = function(self, chartPaths)
	local cacheDatas = {}
	
	for _, path in ipairs(chartPaths) do
		for _, cacheData in ipairs(self:getCacheDatasForPath(path)) do
			cacheDatas[#cacheDatas + 1] = cacheData
		end
	end
	
	if chartPaths[1]:find("%.bm[sel]$") and cacheDatas[1] then
		self:processCacheDataNames(cacheDatas)
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
	else
		return name, #name + 1
	end
end
CacheDataFactory.processCacheDataNames = function(self, cacheDatas)
	local titleTable = {}
	local title = cacheDatas[1].title
	local name, bracketStart = trimName(title)
	print(title, name, bracketStart)
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
	if validate(line) then
		return line
	else
		return iconv(line, "UTF-8", "SHIFT-JIS") or iconv(line, "UTF-8", "EUC-KR") or iconv(line, "UTF-8", "US-ASCII") or line
	end
end

CacheDataFactory.getBMS = function(self, path)
	local noteChart = getNoteChart(path)
	
	if not noteChart then return {} end
	
	return {{
		path = path,
		hash = "",
		container = 0,
		title = fix(noteChart:hashGet("TITLE") or ""),
		artist = fix(noteChart:hashGet("ARTIST") or "artist"),
		source = "BMS",
		tags = "",
		name = nil,
		level = tonumber(noteChart:hashGet("PLAYLEVEL")),
		creator = fix(noteChart:hashGet("ARTIST") or "artist"),
		audioPath = "",
		stagePath = fix(noteChart:hashGet("STAGEFILE") or ""),
		previewTime = 0,
		noteCount = 1000,
		length = 300,
		bpm = 120,
		inputMode = noteChart.inputMode:getString()
	}}
end

CacheDataFactory.getOsu = function(self, path)
	local noteChart = getNoteChart(path)
	
	if not noteChart then return {} end
	
	return {{
		path = path,
		hash = "",
		container = 0,
		title = fix(noteChart:hashGet("Title") or ""),
		artist = fix(noteChart:hashGet("Artist") or ""),
		source = fix(noteChart:hashGet("Source") or ""),
		tags = "",
		name = fix(noteChart:hashGet("Version") or ""),
		level = 0,
		creator = fix(noteChart:hashGet("Creator") or ""),
		audioPath = fix(noteChart:hashGet("AudioFilename") or ""),
		stagePath = fix(noteChart:hashGet("Background") or ""),
		previewTime = 0,
		noteCount = 1000,
		length = 300,
		bpm = 120,
		inputMode = noteChart.inputMode:getString()
	}}
end

CacheDataFactory.getQuaver = function(self, path)
	local noteChart = getNoteChart(path)
	
	if not noteChart then return {} end
	
	return {{
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
		previewTime = noteChart:hashGet("SongPreviewTime"),
		noteCount = 1000,
		length = 300,
		bpm = 120,
		inputMode = noteChart.inputMode:getString()
	}}
end

local o2jamDifficultyNames = {"Easy", "Normal", "Hard"}
CacheDataFactory.getO2Jam = function(self, path)
	local file = love.filesystem.newFile(path)
	file:open("r")
	local ojn = o2jam.OJN:new(file:read(file:getSize()))
	file:close()
	
	local cacheDatas = {}
	for i = 1, 3 do
		cacheDatas[i] = {
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
	
	return cacheDatas
end

return CacheDataFactory
