local PreviewSoundDecoder = require("rizu.engine.audio.PreviewSoundDecoder")
local FakeFilesystem = require("fs.FakeFilesystem")
local AudioPreview = require("rizu.gameplay.AudioPreview")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local ffi = require("ffi")

local test = {}

---@param t testing.T
function test.on_demand_loading(t)
	local fs = FakeFilesystem()
	fs:write("kick.wav", "data")
	fs:write("snare.wav", "data")

	local preview = AudioPreview()
	preview.samples = {"kick.wav", "snare.wav"}
	preview.events = {
		{time = 0.5, sample_index = 1, duration = 0.1, volume = 1},
		{time = 1.5, sample_index = 2, duration = 0.1, volume = 1},
	}

	local loaded = {}
	local function factory(f, path)
		loaded[path] = (loaded[path] or 0) + 1
		local sample_rate = 44100
		local duration = 0.1
		return FakeSoundDecoder(math.floor(duration * sample_rate), sample_rate, 2)
	end

	local decoder = PreviewSoundDecoder(fs, "", preview, factory)

	-- Construction probes the first sound to get format
	t:eq(loaded["/kick.wav"], 1, "Should have probed kick.wav")
	t:eq(loaded["/snare.wav"], nil, "Should NOT have loaded snare.wav yet")

	-- Seek to 1.0 (after kick, before snare)
	decoder:setPosition(1.0)

	-- At this point, kick's lazy decoder might have been loaded by Mixer during setPosition
	-- if it was active, but at 1.0 kick (0.5-0.6) is NOT active.
	-- However, Mixer:resetActiveSet calls getDuration and other methods.
	-- LazySoundDecoder handles these WITHOUT loading.

	t:eq(loaded["/kick.wav"], 1, "Kick should still only be probed once")
	t:eq(loaded["/snare.wav"], nil, "Snare should still not be loaded")

	-- Read data where snare is active (1.5)
	local buf_len = 44100 * 2 * 2 * 1 -- 1 second
	local buf = ffi.new("int16_t[?]", buf_len / 2)

	decoder:getData(buf, buf_len) -- reads 1.0 to 2.0

	t:eq(loaded["/snare.wav"], 1, "Snare should have been loaded on-demand during getData")

	decoder:release()
end

---@param t testing.T
function test.volume_application(t)
	local fs = FakeFilesystem()
	fs:write("tone.wav", "data")

	local preview = AudioPreview()
	preview.samples = {"tone.wav"}
	preview.events = {
		{time = 0, sample_index = 1, duration = 1.0, volume = 0.5},
	}

	local function factory(f, path)
		local sample_rate = 44100
		local duration = 1.0
		return FakeSoundDecoder(math.floor(duration * sample_rate), sample_rate, 2)
	end

	local decoder = PreviewSoundDecoder(fs, "", preview, factory)

	local buf_len = 44100 * 2 * 2
	local buf = ffi.new("int16_t[?]", buf_len / 2)

	decoder:getData(buf, buf_len)

	-- Check first few samples.
	-- FakeSoundDecoder usually starts with 0 or some value.
	-- Let's compare with a full volume one.

	local preview_full = AudioPreview()
	preview_full.samples = {"tone.wav"}
	preview_full.events = {
		{time = 0, sample_index = 1, duration = 1.0, volume = 1.0},
	}
	local decoder_full = PreviewSoundDecoder(fs, "", preview_full, factory)
	local buf_full = ffi.new("int16_t[?]", buf_len / 2)
	decoder_full:getData(buf_full, buf_len)

	-- Verify volume 0.5
	for i = 0, 100 do
		t:eq(buf[i], math.floor(buf_full[i] * 0.5 + 0.5), "Sample " .. i .. " should have half volume")
	end

	decoder:release()
	decoder_full:release()
end

---@param t testing.T
function test.resource_finder_integration(t)
	local fs = FakeFilesystem()
	fs:createDirectory("my_chart")
	fs:createDirectory("my_chart/audio")
	fs:write("my_chart/audio/bgm.ogg", "data")

	local preview = AudioPreview()
	-- AudioPreview might have "audio/bgm" without extension
	preview.samples = {"audio/bgm"}
	preview.events = {
		{time = 0, sample_index = 1, duration = 10, volume = 1},
	}

	local found_path = nil
	local function factory(f, path)
		found_path = path
		local sample_rate = 44100
		local duration = 10
		return FakeSoundDecoder(math.floor(duration * sample_rate), sample_rate, 2)
	end

	local decoder = PreviewSoundDecoder(fs, "my_chart", preview, factory)
	t:eq(found_path, "my_chart/audio/bgm.ogg", "ResourceFinder should have found the file within 'my_chart' directory")

	decoder:release()
end

return test
