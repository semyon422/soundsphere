local ChartAudioMixer = require("rizu.engine.audio.ChartAudioMixer")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local ffi = require("ffi")

local test = {}

---@param wave audio.Wave
---@param offset integer?
---@param mul integer?
local function fill_wave(wave, offset, mul)
	offset = offset or 0
	mul = mul or 1
	for i = 0, wave.samples_count - 1 do
		wave:setSampleInt(i, 1, offset + i * mul)
		wave:setSampleInt(i, 2, offset + i * mul)
	end
end

---@param t testing.T
function test.single(t)
	---@type rizu.ChartAudioSound[]
	local sounds = {
		{time = 0, name = "a"},
	}

	local decoders = {
		FakeSoundDecoder(4),
	}
	fill_wave(decoders[1].wave, 10)

	local mixer = ChartAudioMixer(sounds, decoders)

	local buf_size = 20
	local buf = ffi.new("int16_t[?]", buf_size)
	local function clean()
		ffi.fill(buf, buf_size * 2, 0)
	end

	t:eq(mixer:getData(buf, 3), 0)
	t:eq(buf[0], 0)
	t:eq(buf[1], 0)
	clean()

	t:eq(mixer:getData(buf, 4), 4)
	t:eq(buf[0], 10)
	t:eq(buf[1], 10)
	clean()

	t:eq(mixer:getData(buf, 5), 4)
	t:eq(buf[0], 11)
	t:eq(buf[1], 11)
	clean()

	local result = {
		[0] = 10, 11, 12, 13,
	}

	mixer:setPosition(0)
	t:eq(mixer:getData(buf, buf_size * 2), 40)
	for i = 0, 9 do
		t:eq(buf[i * 2], result[i] or 0)
	end
end

---@param t testing.T
function test.multiple(t)
	---@type rizu.ChartAudioSound[]
	local sounds = {
		{time = 0, name = "a"},
		{time = 2, name = "b"},
	}

	local decoders = {
		FakeSoundDecoder(4, 1),
		FakeSoundDecoder(4, 1),
	}
	fill_wave(decoders[1].wave, 10)
	fill_wave(decoders[2].wave, 100)

	local mixer = ChartAudioMixer(sounds, decoders)

	local buf_size = 20
	local buf = ffi.new("int16_t[?]", buf_size)
	local function clean()
		ffi.fill(buf, buf_size * 2, 0)
	end
	local function as_table(n)
		local t = {}
		for i = 0, n - 1 do
			table.insert(t, buf[i * 2])
		end
		return t
	end

	local result = {
		[0] = 10, 11, 112, 114, 102, 103, 0
	}

	local function test_by_frames(time)
		mixer:setPosition(time)

		for i = time, #result do
			local v = result[i] or 0
			t:eq(mixer:getPosition(), i)
			t:eq(mixer:getData(buf, 4), 4)
			t:eq(mixer:getPosition(), i + 1)
			t:eq(buf[0], v)
			clean()
		end
	end

	for i = -2, 8 do
		test_by_frames(i)
	end

	mixer:setPosition(0)
	t:eq(mixer:getData(buf, buf_size * 2), 40)
	t:eq(mixer:getPosition(), 10)
	t:tdeq(as_table(7), {10, 11, 112, 114, 102, 103, 0})
	clean()

	mixer:setPosition(3)
	t:eq(mixer:getData(buf, buf_size * 2), 40)
	t:eq(mixer:getPosition(), 13)
	t:tdeq(as_table(4), {114, 102, 103, 0})
	clean()

	mixer:setPosition(-1)
	t:eq(mixer:getData(buf, buf_size * 2), 40)
	t:eq(mixer:getPosition(), 9)
	t:tdeq(as_table(7), {0, 10, 11, 112, 114, 102, 103})
	clean()

	--

	mixer:setPosition(-1)
	t:eq(mixer:getData(buf, 8), 8)
	t:eq(mixer:getPosition(), 1)
	t:tdeq(as_table(4), {0, 10, 0, 0})
	clean()

	t:eq(mixer:getData(buf, 8), 8)
	t:eq(mixer:getPosition(), 3)
	t:tdeq(as_table(4), {11, 112, 0, 0})
	clean()
end

return test
