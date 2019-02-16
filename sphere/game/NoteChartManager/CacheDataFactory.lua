local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local isNoteChart = function(path) return NoteChartFactory:isNoteChart(path) end
local getNoteChart = function(path) return NoteChartFactory:getNoteChart(path) end

local NoteChart = require("ncdk.NoteChart")
local bms = require("bms")
local osu = require("osu")
local o2jam = require("o2jam")

local CacheDataFactory = {}

CacheDataFactory.getCacheData = function(self, path)
	if path:find("%.osu$") then
		return self:getOsu(path)
	elseif path:find("%.bm[sel]$") then
		return self:getBMS(path)
	elseif path:find("%.ojn$") then
		return self:getO2Jam(path)
	end
end

local iconv = require("iconv")
local fix = function(line)
	return iconv(line, "UTF-8", "SHIFT-JIS") or iconv(line, "UTF-8", "EUC-KR") or iconv(line, "UTF-8", "US-ASCII") or line
end

local splitTitle = function(title)
	if title:find("^.+%s?%[.+%]$") then
		return title:match("^(.+)%s?%[(.+)%]$")
	elseif title:find("^.+%s?%(.+%)$") then
		return title:match("^(.+)%s?%((.+)%)$")
	elseif title:find("^.+%s?%-.+%-$") then
		return title:match("^(.+)%s?%-(.+)%-$")
	else
		return title, ""
	end
end
CacheDataFactory.getBMS = function(self, path)
	local noteChart = getNoteChart(path)
	
	local title, name = splitTitle(fix(noteChart:hashGet("TITLE") or ""))
	return {{
		path = path,
		hash = "",
		container = 0,
		title = title,
		artist = fix(noteChart:hashGet("ARTIST") or "artist"),
		source = "BMS",
		tags = "",
		name = name,
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
		audioPath = "",
		stagePath = "",
		previewTime = 0,
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
