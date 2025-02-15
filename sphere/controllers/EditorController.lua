local class = require("class")
local path_util = require("path_util")
local ChartEncoder = require("sph.ChartEncoder")
local ChartDecoder = require("sph.ChartDecoder")
local OsuChartEncoder = require("osu.ChartEncoder")
local NanoChart = require("libchart.NanoChart")
local zlib = require("zlib")
local SphPreview = require("sph.SphPreview")
local ModifierModel = require("sphere.models.ModifierModel")
local Wave = require("audio.Wave")
local base36 = require("bms.base36")

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

	---@type {[number]: string}
	local sounds_by_time = {}

	local ks_index = 1
	for i = 1, #linkedNotes - 1 do
		local key = tonumber(linkedNotes[i]:getColumn():match("^key(.+)$"))
		if key then
			---@type number, number
			local a, b
			local n_a, n_b = linkedNotes[i], linkedNotes[i + 1]
			if n_a:isShort() then
				a, b = n_a:getStartTime(), n_b:getStartTime()
			else
				a, b = n_a:getStartTime(), n_a:getEndTime()
			end

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

			---@type string?
			local comment = n_a.startNote.visualPoint.comment

			local file_name = ks_index .. ".wav"
			if comment then
				local new_index = tonumber(comment:match("^=(.+)$"))
				if new_index then
					ks_index = new_index
					file_name = ks_index .. ".wav"
				else
					file_name = comment .. ".wav"
				end
			end

			local p = n_a.startNote.visualPoint.point
			---@cast p ncdk2.IntervalPoint
			sounds_by_time[p.time:tonumber()] = file_name
			print(p, p.interval, p.time:tonumber(), file_name)

			local path = path_util.join(dir, file_name)
			love.filesystem.write(path, wave:export())
			ks_index = ks_index + 1
		end
	end

	-- local enc = ChartEncoder()
	-- print(enc:encode({chart}))

	print('------------')


	---@type chartedit.Notes
	local notes = editorModel.notes
	for note in notes:iter() do
		local p = note.visualPoint.point
		---@cast p ncdk2.IntervalPoint
		local sound = sounds_by_time[p.time:tonumber()]
		print(p.time:tonumber(), sound, note)
		if sound then
			note.sounds = {{path_util.join(chartview.name, sound), 1}}
		else
			note.sounds = nil
		end
	end
end

function EditorController:exportBmsTemplate()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	local chartview = selectModel.chartview
	local real_dir = chartview.real_dir

	---@type ncdk2.Chart[]
	local stem_charts = {}

	for _, name in ipairs(love.filesystem.getDirectoryItems(real_dir) --[=[@as string[]]=]) do
		if name:match("^stem.+%.sph$") then
			local dec = ChartDecoder()
			local chart = dec:decode(assert(love.filesystem.read(path_util.join(real_dir, name))))[1]
			table.insert(stem_charts, chart)
		end
	end

	print(#stem_charts)

	---@type string[]
	local sounds = {}

	---@type {[string]: integer}
	local sounds_map = {}

	---@param path string
	local function get_sound_index(path)
		if sounds_map[path] then
			return sounds_map[path]
		end
		table.insert(sounds, path)
		sounds_map[path] = #sounds
		return sounds_map[path]
	end

	---@type number
	local tempo

	---@type {time: ncdk.Fraction, column: integer, sound: integer}[]
	local notes = {}

	---@type ncdk.Fraction
	local max_time

	local beat_offset = editorModel.bms_tools.beat_offset

	for column, chart in ipairs(stem_charts) do
		local dir = chart.chartmeta.name
		local linkedNotes = chart.notes:getLinkedNotes()

		local ks_index = 1
		for i = 1, #linkedNotes - 1 do
			local key = tonumber(linkedNotes[i]:getColumn():match("^key(.+)$"))
			if key then
				local n_a = linkedNotes[i]

				---@type string?
				local comment = n_a.startNote.visualPoint.comment

				local file_name = ks_index .. ".wav"
				if comment then
					local new_index = tonumber(comment:match("^=(.+)$"))
					if new_index then
						ks_index = new_index
						file_name = ks_index .. ".wav"
					else
						file_name = comment .. ".wav"
					end
				end

				local path = path_util.join(dir, file_name)
				ks_index = ks_index + 1

				local point = n_a.startNote.visualPoint.point
				---@cast point ncdk2.IntervalPoint

				if not tempo then
					tempo = point.interval:getTempo()
				end

				local time = point.time + beat_offset

				table.insert(notes, {
					time = time,
					column = column,
					sound = get_sound_index(path),
				})

				if not max_time or time > max_time then
					max_time = time
				end
			end
		end
	end

	print("sounds", #sounds)
	if #sounds > 36 ^ 2 - 1 then
		print("too much sounds")
		return
	end

	---@type {[integer]: {[integer]: {time: ncdk.Fraction, sound: integer}[]}}
	local notes_grouped = {}

	for _, note in ipairs(notes) do
		local measure = (note.time / 4):floor()
		notes_grouped[measure] = notes_grouped[measure] or {}
		notes_grouped[measure][note.column] = notes_grouped[measure][note.column] or {}
		table.insert(notes_grouped[measure][note.column], {
			time = note.time / 4 - measure,
			sound = note.sound,
		})
	end

	---@type string[]
	local lines = {
		"",
		"*---------------------- HEADER FIELD",
		"",
		"#PLAYER 1",
		("#TITLE %s"):format(chartview.title),
		("#ARTIST %s"):format(chartview.artist),
		("#SUBARTIST OBJ: %s"):format(chartview.creator),
		("#BPM %s"):format(tempo),
		"#PLAYLEVEL 5",
		"#RANK 3",
		("#TOTAL %s"):format(#notes),
		"#STAGEFILE title.bmp",
		"",
		"#00011:00",
		"#00012:00",
		"#00013:00",
		"#00014:00",
		"#00015:00",
		"#00018:00",
		"#00019:00",
		"",
	}

	for i, path in ipairs(sounds) do
		table.insert(lines, ("#WAV%s %s"):format(base36.tostring(i), path))
	end

	table.insert(lines, "")

	local max_measure = (max_time / 4):ceil()

	local snap = 384

	for measure = 0, max_measure do
		if notes_grouped[measure] then
			for column = 1, table.maxn(notes_grouped[measure]) do
				local column_notes = notes_grouped[measure][column]
				if not column_notes then
					table.insert(lines, ("#%03d01:00"):format(measure))
				else
					---@type string[]
					local value = {}
					for i = 1, snap do
						value[i] = "00"
					end
					for _, note in ipairs(column_notes) do
						local time = (note.time * snap):floor() + 1
						value[time] = base36.tostring(note.sound)
					end
					table.insert(lines, ("#%03d01:%s"):format(measure, table.concat(value)))
				end
			end
			table.insert(lines, "")
		end
	end

	local out_path = path_util.join(real_dir, "template.bme")
	love.filesystem.write(out_path, table.concat(lines, "\r\n"))
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
