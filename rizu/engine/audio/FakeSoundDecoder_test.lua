local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local ffi = require("ffi")

local test = {}

---@param t testing.T
function test.test_1(t)
	local samples_count = 2
	local dec = FakeSoundDecoder(samples_count)
	for i = 1, samples_count do
		dec.wave:setSampleInt(i - 1, 1, i)
		dec.wave:setSampleInt(i - 1, 2, i + 10)
	end

	local buf = ffi.new("int16_t[?]", samples_count * 2)

	t:eq(dec:getData(buf, 3), 0)
	t:eq(buf[0], 0)
	t:eq(buf[1], 0)

	t:eq(dec:getData(buf, 5), 4)
	t:eq(buf[0], dec.wave.data_buf[0])
	t:eq(buf[1], dec.wave.data_buf[1])

	t:eq(dec:getData(buf, 40), 4)
	t:eq(buf[0], dec.wave.data_buf[2])
	t:eq(buf[1], dec.wave.data_buf[3])

	t:eq(dec:getData(buf, 4), 0)
	t:eq(buf[0], dec.wave.data_buf[2])
	t:eq(buf[1], dec.wave.data_buf[3])

	dec:setPosition(0)

	t:eq(dec:getData(buf, 4), 4)
	t:eq(buf[0], dec.wave.data_buf[0])
	t:eq(buf[1], dec.wave.data_buf[1])
end

--- Same test for BassSoundDecoder
---@param t testing.T
function test.test_2(t)
	local duration = 0.1
	local samples_count = math.floor(44100 * duration)
	local size = samples_count * 2 * 2

	local dec = FakeSoundDecoder(samples_count)

	local buf_len = 17003 -- rounds to 17000
	local buf = ffi.new("uint8_t[?]", buf_len)

	t:eq(dec:getPosition(), 0)

	t:eq(dec:getData(buf, buf_len), 17000)
	t:lt(dec:getPosition() - 17000 / size * duration, 1e-9)

	t:eq(dec:getData(buf, buf_len), 640)
	t:eq(dec:getData(buf, buf_len), 0)
	t:eq(dec:getData(buf, buf_len), 0)

	t:eq(dec:getPosition(), duration)

	dec:setPosition(0.05)
	t:eq(dec:getPosition(), 0.05)
	t:eq(dec:getData(buf, buf_len), 8820)
	t:eq(dec:getPosition(), duration)
end

return test
