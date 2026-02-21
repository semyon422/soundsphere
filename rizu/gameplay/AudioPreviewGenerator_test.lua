local FakeFilesystem = require("fs.FakeFilesystem")
local Wave = require("audio.Wave")
local AudioPreviewGenerator = require("rizu.gameplay.AudioPreviewGenerator")
local AudioPreview = require("rizu.gameplay.AudioPreview")
local TestChartFactory = require("sea.chart.TestChartFactory")

local test = {}

---@param t testing.T
function test.generate(t)
	local fs = FakeFilesystem()
	local generator = AudioPreviewGenerator(fs)
	
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
	notes[1].data.sounds = {{"hit.wav", 1.0}}
	notes[2].data.sounds = {{"hit.wav", 0.5}}
	
	generator:generate(res.chart, "chart", "test_hash")
	
	local preview_path = "userdata/audio_previews/test_hash.audio_preview"
	local preview_data = fs:read(preview_path)
	t:assert(preview_data, "preview file should exist")
	
	local preview = AudioPreview()
	preview:decode(preview_data)
	
	t:eq(#preview.samples, 1)
	t:eq(preview.samples[1], "hit.wav")
	t:eq(#preview.events, 2)
	
	t:eq(preview.events[1].time, 1.0)
	t:eq(preview.events[1].sample_index, 0)
	t:eq(preview.events[1].duration, 1.0)
	t:eq(preview.events[1].volume, 1.0)
	
	t:eq(preview.events[2].time, 2.0)
	t:eq(preview.events[2].sample_index, 0)
	t:eq(preview.events[2].duration, 1.0)
	t:assert(math.abs(preview.events[2].volume - 0.5) < 0.01)
end

return test
