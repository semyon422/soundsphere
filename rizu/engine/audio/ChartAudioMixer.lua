local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local ffi = require("ffi")

---@class rizu.ChartAudioMixer: rizu.ISoundDecoder
---@operator call: rizu.ChartAudioMixer
local ChartAudioMixer = ISoundDecoder + {}

---@param sounds rizu.ChartAudioSound[]
---@param decoders {[integer]: rizu.ISoundDecoder}
function ChartAudioMixer:new(sounds, decoders)
	---@type {time: number, duration: number, decoder: rizu.ISoundDecoder}[]
	self.sounds = {}

	self.start_pos = math.huge
	self.end_pos = -math.huge

	for i, sound in ipairs(sounds) do
		self:addSound(sound, decoders[i])
	end

	self.position = 0
end

---@private
---@param sound rizu.ChartAudioSound
---@param decoder rizu.ISoundDecoder?
function ChartAudioMixer:addSound(sound, decoder)
	if not decoder then
		return
	end

	table.insert(self.sounds, {
		decoder = decoder,
		time = sound.time,
		duration = decoder:getDuration(),
	})

	local start_pos = decoder:secondsToBytes(sound.time)
	local end_pos = start_pos + decoder:getBytesDuration()

	self.start_pos = math.min(self.start_pos, start_pos)
	self.end_pos = math.max(self.end_pos, end_pos)
end

function ChartAudioMixer:release()
	for _, sound in ipairs(self.sounds) do
		sound.decoder:release()
	end
end

---@param dst {[integer]: integer}
---@param src {[integer]: integer}
---@param size integer
local function add_buffer(dst, src, size)
	---@type {[integer]: integer}
	local dst_ptr = ffi.cast("int16_t*", dst)
	---@type {[integer]: integer}
	local src_ptr = ffi.cast("int16_t*", src)

	for i = 0, size - 1 do
		local sum = dst_ptr[i] + src_ptr[i]

		if sum > 32767 then
			dst_ptr[i] = 32767
		elseif sum < -32768 then
			dst_ptr[i] = -32768
		else
			dst_ptr[i] = sum
		end
	end
end

---@param buf ffi.cdata*
---@param len integer
---@return integer
function ChartAudioMixer:getData(buf, len)
	len = self:floorBytes(len)

	---@type {[integer]: integer}
	buf = ffi.cast("int16_t*", buf)

	local dec_buf = ffi.new("int16_t[?]", len / 2)

	-- TOOO: optimize sounds iteration

	local pos = self.position
	for _, sound in ipairs(self.sounds) do
		local start_pos = self:secondsToBytes(sound.time)
		local end_pos = start_pos + sound.decoder:getBytesDuration()

		if start_pos > pos + len then
			break
		end

		local need_bytes = math.min(pos + len, end_pos) - math.max(pos, start_pos)
		local offset = math.max(start_pos - pos, 0)
		offset = offset / 2

		if need_bytes > 0 then
			local sound_pos = math.max(pos - start_pos, 0)
			if sound_pos >= 0 and sound_pos ~= sound.decoder:getBytesPosition() then
				sound.decoder:setBytesPosition(sound_pos)
			end

			local bytes = sound.decoder:getData(dec_buf, need_bytes)
			add_buffer(buf + offset, dec_buf, bytes / 2)
		end
	end

	self.position = self.position + len

	return len
end

---@param bytes integer
---@return integer
function ChartAudioMixer:floorBytes(bytes)
	local mul = self:getChannelCount() * self:getBytesPerSample()
	return math.floor(bytes / mul) * mul
end

---@return number
function ChartAudioMixer:getPosition()
	return self:bytesToSeconds(self.position)
end

---@param pos number
function ChartAudioMixer:setPosition(pos)
	self.position = self:secondsToBytes(pos)
end

---@return integer
function ChartAudioMixer:getBytesDuration()
	return self.end_pos - self.start_pos
end

---@param pos integer
---@return number
function ChartAudioMixer:bytesToSeconds(pos)
	return self.sounds[1].decoder:bytesToSeconds(pos)
end

---@param pos number
---@return integer
function ChartAudioMixer:secondsToBytes(pos)
	return self.sounds[1].decoder:secondsToBytes(pos)
end

---@return integer
function ChartAudioMixer:getSampleRate()
	return self.sounds[1].decoder:getSampleRate()
end

---@return integer
function ChartAudioMixer:getChannelCount()
	return self.sounds[1].decoder:getChannelCount()
end

---@return integer
function ChartAudioMixer:getBytesPerSample()
	return self.sounds[1].decoder:getBytesPerSample()
end

return ChartAudioMixer
