local class = require("class")
local path_util = require("path_util")
local ChartEncoder = require("sph.ChartEncoder")
local OsuChartEncoder = require("osu.ChartEncoder")
local NanoChart = require("libchart.NanoChart")
local zlib = require("zlib")
local SphPreview = require("sph.SphPreview")
local ModifierModel = require("sphere.models.ModifierModel")
local Wave = require("audio.Wave")

---@class sphere.EditorController
---@operator call: sphere.EditorController
local EditorController = class()

---@param selectModel sphere.SelectModel
---@param editorModel sphere.EditorModel
---@param noteSkinModel sphere.NoteSkinModel
---@param configModel sphere.ConfigModel
---@param resourceModel sphere.ResourceModel
---@param windowModel sphere.WindowModel
---@param cacheModel sphere.CacheModel
---@param fileFinder sphere.FileFinder
---@param previewModel sphere.PreviewModel
---@param playContext sphere.PlayContext
function EditorController:new(
	selectModel,
	editorModel,
	noteSkinModel,
	configModel,
	resourceModel,
	windowModel,
	cacheModel,
	fileFinder,
	previewModel,
	playContext
)
	self.selectModel = selectModel
	self.editorModel = editorModel
	self.noteSkinModel = noteSkinModel
	self.configModel = configModel
	self.resourceModel = resourceModel
	self.windowModel = windowModel
	self.cacheModel = cacheModel
	self.fileFinder = fileFinder
	self.previewModel = previewModel
	self.playContext = playContext
end

function EditorController:load()

	local selectModel = self.selectModel
	local editorModel = self.editorModel
	local configModel = self.configModel
	local fileFinder = self.fileFinder

	local chart = selectModel:loadChart()

	if love.keyboard.isDown("lshift") then
		ModifierModel:apply(self.playContext.modifiers, chart)
	end

	local chartview = selectModel.chartview

	local noteSkin = self.noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()
	noteSkin.editor = true

	editorModel.noteSkin = noteSkin
	editorModel.chart = chart
	editorModel:load()

	self.previewModel:stop()

	fileFinder:reset()
	if configModel.configs.settings.gameplay.skin_resources_top_priority then
		fileFinder:addPath(noteSkin.directoryPath)
		fileFinder:addPath(chartview.location_dir)
	else
		fileFinder:addPath(chartview.location_dir)
		fileFinder:addPath(noteSkin.directoryPath)
	end
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(chart, function()
		editorModel:loadResources()
	end)

	self.windowModel:setVsyncOnSelect(false)
end

function EditorController:unload()
	self.editorModel:unload()

	self.windowModel:setVsyncOnSelect(true)
end

function EditorController:sliceKeysounds()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	---@type audio.SoundData
	local soundData = editorModel.mainAudio.soundData
	if not soundData then
		return
	end

	local chartview = selectModel.chartview
	local real_dir = chartview.real_dir

	local dir = path_util.join(real_dir, chartview.name)
	assert(love.filesystem.createDirectory(dir))

	---@type ncdk2.Chart
	local chart = editorModel.chart

	local linkedNotes = chart.notes:getLinkedNotes()

	local sample_rate = soundData:getSampleRate()
	local channels_count = soundData:getChannelCount()

	for i = 1, #linkedNotes - 1 do
		local key = tonumber(linkedNotes[i]:getColumn():match("^key(.+)$"))
		if key then
			local a, b = linkedNotes[i]:getStartTime(), linkedNotes[i + 1]:getStartTime()

			local sample_offset = math.floor(a * sample_rate)
			local sample_count = math.floor((b - a) * sample_rate)

			local wave = Wave()
			wave:initBuffer(channels_count, sample_count)

			for j = 0, sample_count - 1 do
				for c = 1, channels_count do
					local sample = soundData:getSample(sample_offset + j, c)
					wave:setSample(j, c, sample * 32768)
				end
			end

			local path = path_util.join(dir, i .. ".wav")
			local data = wave:export()
			love.filesystem.write(path, data)
		end
	end
end

function EditorController:save()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()
	self.editorModel:genGraphs()

	local encoder = ChartEncoder()
	local data = encoder:encode({editorModel.chart})

	local chartview = selectModel.chartview
	local path = chartview.location_path:gsub(".sph$", "") .. ".sph"

	assert(love.filesystem.write(path, data))

	self.cacheModel:startUpdate(chartview.dir, chartview.location_id)
end

function EditorController:saveToOsu()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()

	local encoder = OsuChartEncoder()
	local data = encoder:encode({editorModel.chart})

	local chartview = selectModel.chartview
	local path = chartview.location_path:gsub(".osu$", ""):gsub(".sph$", "") .. ".sph.osu"

	assert(love.filesystem.write(path, data))
end

function EditorController:saveToNanoChart()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()

	local nanoChart = NanoChart()

	local abs_notes = {}

	for noteDatas, inputType, inputIndex, layerDataIndex in editorModel.noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if inputType == "key" and (noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart") then
				abs_notes[#abs_notes + 1] = {
					time = noteData.timePoint.absoluteTime,
					type = 1,
					input = 1,
				}
			end
		end
	end

	local emptyHash = string.char(0):rep(16)
	local content = nanoChart:encode(emptyHash, editorModel.noteChart.inputMode.key, abs_notes)
	local compressedContent = zlib.compress(content)

	local chartview = selectModel.chartview

	local path = chartview.real_path

	local f = assert(io.open(path .. ".nanochart_compressed", "w"))
	f:write(compressedContent)
	f:close()
	local f = assert(io.open(path .. ".nanochart", "w"))
	f:write(content)
	f:close()

	local exp = NoteChartExporter()
	exp.noteChart = editorModel.noteChart
	local sph_chart = exp:export()

	local content = SphPreview:encodeLines(exp.sph.sphLines:encode())
	local compressedContent = zlib.compress(content)

	local content1 = SphPreview:encodeLines(exp.sph.sphLines:encode(), 1)
	local compressedContent1 = zlib.compress(content1)

	local f = assert(io.open(path .. ".preview0_compressed", "w"))
	f:write(compressedContent)
	f:close()
	local f = assert(io.open(path .. ".preview0", "w"))
	f:write(content)
	f:close()
	local f = assert(io.open(path .. ".preview1_compressed", "w"))
	f:write(compressedContent1)
	f:close()
	local f = assert(io.open(path .. ".preview1", "w"))
	f:write(content1)
	f:close()
	-- local f = assert(io.open(path .. ".preview_lines", "w"))
	-- f:write(require("inspect")(lines))
	-- f:close()
end

---@param event table
function EditorController:receive(event)
	self.editorModel:receive(event)
	if event.name == "filedropped" then
		self:filedropped(event[1])
	end
end

local exts = {
	mp3 = true,
	ogg = true,
}

---@param file love.File
function EditorController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")

	local _name, ext = path:match("^(.+)%.(.-)$")
	if not exts[ext] then
		return
	end

	local audioName = _name:match("^.+/(.-)$")
	local chartSetPath = "userdata/charts/editor/" .. os.time() .. " " .. audioName

	love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, file:read())
end

return EditorController
