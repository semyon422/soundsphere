local FakeFilesystem = require("fs.FakeFilesystem")
local Wave = require("audio.Wave")
local AudioPreviewGenerator = require("rizu.gameplay.AudioPreviewGenerator")
local AudioPreview = require("rizu.gameplay.AudioPreview")
local TestChartFactory = require("sea.chart.TestChartFactory")
local WaveSoundDecoder = require("rizu.engine.audio.WaveSoundDecoder")

local test = {}

---@param t testing.T
function test.generate(t)
	local fs = FakeFilesystem()
	local generator = AudioPreviewGenerator(fs, function(data)
		return WaveSoundDecoder(data)
	end)

	-- Create a fake wav file (1 second)
	local wave = Wave()
	wave.sample_rate = 44100
	wave:initBuffer(1, 44100)
	local wav_data = wave:encode()

	fs:createDirectory("chart")
	fs:write("chart/hit.wav", wav_data)

	-- Create a chart
	local tcf = TestChartFactory()
	local res = tcf:create("4key", {
		{time = 1.0, column = 1},
		{time = 2.0, column = 2},
	})

	-- Manually add sounds to notes
	local notes = res.chart.notes.notes
	notes[1].data.sounds = {{"hit.wav", 1.0}} ---@diagnostic disable-line: no-unknown
	notes[2].data.sounds = {{"hit.wav", 0.5}} ---@diagnostic disable-line: no-unknown

	generator:generate(res.chart, "chart", "test_hash")

	local preview_path = "userdata/audio_previews/test_hash.audio_preview"
	local preview_data = fs:read(preview_path)
	t:assert(preview_data, "preview file should exist")
	---@cast preview_data -?

	local preview = AudioPreview()
	preview:decode(preview_data)

	t:eq(#preview.samples, 1)
	t:eq(preview.samples[1], "hit.wav")
	t:eq(#preview.events, 2)

	t:eq(preview.events[1].time, 1.0)
	t:eq(preview.events[1].sample_index, 1)
	t:eq(preview.events[1].duration, 1.0)
	t:eq(preview.events[1].volume, 1.0)

	t:eq(preview.events[2].time, 2.0)
	t:eq(preview.events[2].sample_index, 1)
	t:eq(preview.events[2].duration, 1.0)
	t:aeq(preview.events[2].volume, 0.5, 0.01)
end

---@param t testing.T
function test.generate_main_audio(t)
	local fs = FakeFilesystem()
	local generator = AudioPreviewGenerator(fs, function(data)
		return WaveSoundDecoder(data)
	end)

	-- Create a fake wav file (1 second)
	local wave = Wave()
	wave.sample_rate = 44100
	wave:initBuffer(1, 44100)
	local wav_data = wave:encode()

	fs:createDirectory("chart")
	fs:write("chart/bgm.wav", wav_data)
	fs:write("chart/hit.wav", wav_data)

	-- Create a chart
	local tcf = TestChartFactory()
	local res = tcf:create("4key", {
		{time = 1.0, column = 1},
		{time = 2.0, column = 2},
		{time = 0.0, column = "audio"},
	})

	-- Manually add sounds to notes
	local notes = res.chart.notes.notes
	-- After compute(), notes are sorted by time:
	-- index 1: time 0.0, column "audio"
	-- index 2: time 1.0, column "key1"
	-- index 3: time 2.0, column "key2"
	notes[1].data.sounds = {{"bgm.wav", 1.0}} ---@diagnostic disable-line: no-unknown
	notes[2].data.sounds = {{"hit.wav", 1.0}} ---@diagnostic disable-line: no-unknown
	notes[3].data.sounds = {{"hit.wav", 0.5}} ---@diagnostic disable-line: no-unknown

	generator:generate(res.chart, "chart", "test_hash_main")

	local preview_path = "userdata/audio_previews/test_hash_main.audio_preview"
	local preview_data = fs:read(preview_path)
	t:assert(preview_data, "preview file should exist")
	---@cast preview_data -?

	local preview = AudioPreview()
	preview:decode(preview_data)

	-- Should only contain bgm.wav
	t:eq(#preview.samples, 1)
	t:eq(preview.samples[1], "bgm.wav")
	t:eq(#preview.events, 1)

	t:eq(preview.events[1].time, 0.0)
	t:eq(preview.events[1].sample_index, 1)
	t:eq(preview.events[1].duration, 1.0)
	t:eq(preview.events[1].volume, 1.0)
end

return test
