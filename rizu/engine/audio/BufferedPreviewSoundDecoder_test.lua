local BufferedPreviewSoundDecoder = require("rizu.engine.audio.BufferedPreviewSoundDecoder")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local YieldingFakeSoundDecoder = require("rizu.engine.audio.YieldingFakeSoundDecoder")
local ffi = require("ffi")

local test = {}

---@param t testing.T
function test.basic_preloading(t)
	local sample_rate = 44100
	local channels = 2
	local bytes_per_sample = 2
	local duration = 10
	local total_samples = duration * sample_rate
	local underlying = FakeSoundDecoder(total_samples, sample_rate, channels)

	-- Fill underlying with some data
	local u_buf_len = total_samples * channels * bytes_per_sample
	local u_buf = ffi.cast("int8_t*", underlying.wave.byte_ptr)
	for i = 0, u_buf_len - 1 do
		u_buf[i] = i % 128
	end

	local buffered = BufferedPreviewSoundDecoder(underlying, 0.1) -- 0.1s buffer

	-- Buffer should be filled upon construction or first resume in getData
	local read_len = 1024
	local read_buf = ffi.new("int8_t[?]", read_len)
	local read = buffered:getData(read_buf, read_len)

	t:eq(read, read_len, "Should read full requested length")
	t:eq(buffered:getBytesPosition(), read_len, "Position should advance")

	for i = 0, read_len - 1 do
		t:eq(read_buf[i], i % 128, "Data should match at index " .. i)
	end
end

---@param t testing.T
function test.non_blocking_yield(t)
	local sample_rate = 44100
	local channels = 2
	local bytes_per_sample = 2
	local duration = 10
	local total_samples = duration * sample_rate

	-- Use YieldingFakeSoundDecoder to wrap FakeSoundDecoder
	local underlying = YieldingFakeSoundDecoder(FakeSoundDecoder(total_samples, sample_rate, channels))
	-- Accessing underlying.decoder because FakeSoundDecoder is what actually has the buffer
	local u_buf = ffi.cast("int8_t*", underlying.decoder.wave.byte_ptr)
	ffi.fill(u_buf, 10000, 7)

	-- BufferedPreviewSoundDecoder will call getSampleRate, getChannelCount, etc. in new()
	-- YieldingFakeSoundDecoder:new(decoder) is fine, but BufferedPreviewSoundDecoder constructor
	-- calls methods that YIELD.
	-- This means BufferedPreviewSoundDecoder constructor MUST be called inside a coroutine
	-- if the decoder methods yield.

	-- Wait, let's re-examine BufferedPreviewSoundDecoder:new()
	-- It calls decoder:getSampleRate(), getChannelCount(), getBytesPerSample(), getDuration()
	-- If they yield, BufferedPreviewSoundDecoder:new() will yield.

	local buffered
	local co = coroutine.create(function()
		buffered = BufferedPreviewSoundDecoder(underlying, 1.0)
	end)

	-- Resume until coroutine is dead
	while coroutine.status(co) ~= "dead" do
		local ok, err = coroutine.resume(co)
		if not ok then error(err) end
	end
	-- Now buffered should be initialized

	local read_len = 1024
	local read_buf = ffi.new("int8_t[?]", read_len)

	-- First getData will resume the preloader.
	-- The preloader will call underlying:getData which will yield.
	-- BufferedPreviewSoundDecoder:getData should then return silence.
	local read = buffered:getData(read_buf, read_len)

	t:eq(read, read_len, "Should return full length (silence)")
	for i = 0, read_len - 1 do
		t:eq(read_buf[i], 0, "Data should be silence (0) at index " .. i)
	end

	-- Manually resume the preloader since we are in a mock test with no external driver
	coroutine.resume(buffered.preloader_co)

	-- Second getData call will now read from the chunk added by the previous preloader step.
	local read2 = buffered:getData(read_buf, read_len)
	t:eq(read2, read_len, "Should return full length (real data now)")
	t:eq(read_buf[0], 7, "Should have read real data (7)")
end

---@param t testing.T
function test.seek(t)
	local sample_rate = 44100
	local duration = 10
	local underlying = FakeSoundDecoder(duration * sample_rate, sample_rate, 2)
	local buffered = BufferedPreviewSoundDecoder(underlying, 1.0)

	local u_buf = ffi.cast("int8_t*", underlying.wave.byte_ptr)
	for i = 0, 100000 do u_buf[i] = i % 120 + 1 end -- Use +1 to avoid 0s

	buffered:setBytesPosition(50000)
	t:eq(buffered:getBytesPosition(), 50000)

	local read_len = 100
	local read_buf = ffi.new("int8_t[?]", read_len)

	-- Since FakeSoundDecoder doesn't yield, setBytesPosition already triggered 
	-- the preloader to seek AND fetch one chunk (chunk_size=4096).
	-- So the data should be available IMMEDIATELY.
	buffered:getData(read_buf, read_len)

	t:eq(read_buf[0], 50000 % 120 + 1, "Data should match after seek")
end

return test
