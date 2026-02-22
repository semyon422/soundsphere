local class = require("class")
local ISoundDecoder = require("rizu.engine.audio.ISoundDecoder")
local FakeSoundDecoder = require("rizu.engine.audio.FakeSoundDecoder")
local rbtree = require("aqua.rbtree")
local ffi = require("ffi")

local next_entry_id = 1

---@class rizu.ChartAudioMixer.NodeWrap
---@operator call: rizu.ChartAudioMixer.NodeWrap
---@field entry rizu.ChartAudioMixer.Entry
---@field is_search_key boolean?
local NodeWrap = class()

---@param entry rizu.ChartAudioMixer.Entry
---@param is_search_key boolean?
function NodeWrap:new(entry, is_search_key)
	self.entry = entry
	self.is_search_key = is_search_key
end

function NodeWrap:tie_breaker(other)
	if self == other then return false end
	if self.is_search_key ~= other.is_search_key then
		-- Search keys are considered "smaller" than real entries at the same pos
		-- to ensure lower_bound finds the first entry.
		return self.is_search_key
	end
	if self.is_search_key then
		-- Tie-breaker for two different search keys at the same pos
		return tostring(self) < tostring(other)
	end
	-- Tie-breaker for two different real entries at the same pos
	return self.entry.id < other.entry.id
end

---@class rizu.ChartAudioMixer.StartNodeWrap: rizu.ChartAudioMixer.NodeWrap
---@operator call: rizu.ChartAudioMixer.StartNodeWrap
local StartNodeWrap = NodeWrap + {}

function StartNodeWrap:__lt(other)
	if self.entry.start_pos ~= other.entry.start_pos then
		return self.entry.start_pos < other.entry.start_pos
	end
	return self:tie_breaker(other)
end

---@class rizu.ChartAudioMixer.EndNodeWrap: rizu.ChartAudioMixer.NodeWrap
---@operator call: rizu.ChartAudioMixer.EndNodeWrap
local EndNodeWrap = NodeWrap + {}

function EndNodeWrap:__lt(other)
	if self.entry.end_pos ~= other.entry.end_pos then
		return self.entry.end_pos < other.entry.end_pos
	end
	return self:tie_breaker(other)
end

---@class rizu.ChartAudioMixer.Entry
---@operator call: rizu.ChartAudioMixer.Entry
---@field id integer
---@field decoder rizu.ISoundDecoder
---@field time number
---@field duration number
---@field start_pos integer
---@field end_pos integer
---@field start_wrap rizu.ChartAudioMixer.StartNodeWrap
---@field end_wrap rizu.ChartAudioMixer.EndNodeWrap
local Entry = class()

---@param decoder rizu.ISoundDecoder
---@param time number
function Entry:new(decoder, time)
	self.decoder = decoder
	self.time = time
	self.duration = decoder:getDuration()
	self.start_pos = decoder:secondsToBytes(time)
	self.end_pos = self.start_pos + decoder:getBytesDuration()

	self.id = next_entry_id
	next_entry_id = next_entry_id + 1

	self.start_wrap = StartNodeWrap(self)
	self.end_wrap = EndNodeWrap(self)
end

---@class rizu.ChartAudioMixer: rizu.ISoundDecoder
---@operator call: rizu.ChartAudioMixer
local ChartAudioMixer = ISoundDecoder + {}

---@param sounds rizu.ChartAudioSound[]
---@param decoders {[integer]: rizu.ISoundDecoder}
function ChartAudioMixer:new(sounds, decoders)
	self.tree_start = rbtree.new()
	self.tree_end = rbtree.new()
	---@type {[rizu.ISoundDecoder]: rizu.ChartAudioMixer.Entry}
	self.decoder_to_entry = {}

	self.start_pos = math.huge
	self.end_pos = -math.huge
	self.max_duration_bytes = 0

	self.position = 0
	---@type {[rizu.ChartAudioMixer.Entry]: boolean}
	self.active_sounds = {}
	self.next_to_add = nil
	self.next_to_remove = nil

	self.dec_buf_len = 0
	self.dec_buf = nil
	self.mix_buf = nil

	self.sample_rate = 44100
	self.channels = 2
	self.bytes_per_sample = 2

	for i, sound in ipairs(sounds) do
		self:addSound(sound, decoders[i])
	end

	if self.tree_start.size == 0 then
		self.empty = true
		self.start_pos = 0
		self.end_pos = 0
		self.dummy_decoder = FakeSoundDecoder(1, 44100, 2)
	end

	self:resetActiveSet()
end

---@param tree rbtree.Tree
---@param key table
---@return rbtree.Node?
local function find_lower_bound(tree, key)
	local x = tree.root
	local res = nil
	while x do
		if not (x.key < key) then
			res = x
			x = x.left
		else
			x = x.right
		end
	end
	return res
end

---@private
function ChartAudioMixer:resetActiveSet()
	self.active_sounds = {}
	local pos = self.position

	-- Pointers for incremental updates
	local search_start = StartNodeWrap({start_pos = pos}, true)
	self.next_to_add = find_lower_bound(self.tree_start, search_start)

	local search_end = EndNodeWrap({end_pos = pos}, true)
	self.next_to_remove = find_lower_bound(self.tree_end, search_end)

	-- Initial active set: sounds that started before pos and end at or after pos
	if not self.empty then
		local search_seek = StartNodeWrap({start_pos = pos - self.max_duration_bytes}, true)
		local node = find_lower_bound(self.tree_start, search_seek) or self.tree_start:min()
		while node and node.key.entry.start_pos < pos do
			local entry = node.key.entry
			if entry.end_pos >= pos then
				self.active_sounds[entry] = true
			end
			node = node:next()
		end
	end
end

---@param sound rizu.ChartAudioSound
---@param decoder rizu.ISoundDecoder?
function ChartAudioMixer:addSound(sound, decoder)
	if not decoder then
		return
	end

	if self.empty or self.tree_start.size == 0 then
		self.sample_rate = decoder:getSampleRate()
		self.channels = decoder:getChannelCount()
		self.bytes_per_sample = decoder:getBytesPerSample()
		self.empty = false
		self.start_pos = math.huge
		self.end_pos = -math.huge
		self.max_duration_bytes = 0
		if self.dummy_decoder then
			self.dummy_decoder:release()
			self.dummy_decoder = nil
		end
	end

	local entry = Entry(decoder, sound.time)
	self.decoder_to_entry[decoder] = entry

	self.tree_start:insert(entry.start_wrap)
	self.tree_end:insert(entry.end_wrap)

	self.start_pos = math.min(self.start_pos, entry.start_pos)
	self.end_pos = math.max(self.end_pos, entry.end_pos)
	self.max_duration_bytes = math.max(self.max_duration_bytes, entry.end_pos - entry.start_pos)

	self:resetActiveSet()
end

---@param decoder rizu.ISoundDecoder
function ChartAudioMixer:removeSound(decoder)
	local entry = self.decoder_to_entry[decoder]
	if not entry then
		return
	end

	self.tree_start:remove(entry.start_wrap)
	self.tree_end:remove(entry.end_wrap)

	self.decoder_to_entry[decoder] = nil

	if entry.start_pos == self.start_pos or entry.end_pos == self.end_pos or (entry.end_pos - entry.start_pos) == self.max_duration_bytes then
		self:recalculateBounds()
	end

	if self.tree_start.size == 0 then
		self.empty = true
		self.start_pos = 0
		self.end_pos = 0
		self.max_duration_bytes = 0
		self.dummy_decoder = FakeSoundDecoder(1, 44100, 2)
	end

	self:resetActiveSet()
end

function ChartAudioMixer:recalculateBounds()
	self.start_pos = math.huge
	self.end_pos = -math.huge
	self.max_duration_bytes = 0

	for node in self.tree_start:iter() do
		local entry = node.key.entry
		self.start_pos = math.min(self.start_pos, entry.start_pos)
		self.end_pos = math.max(self.end_pos, entry.end_pos)
		self.max_duration_bytes = math.max(self.max_duration_bytes, entry.end_pos - entry.start_pos)
	end

	if self.tree_start.size == 0 then
		self.start_pos = 0
		self.end_pos = 0
	end
end

---@return number
---@return number
function ChartAudioMixer:getTimeBounds()
	return self:bytesToSeconds(self.start_pos), self:bytesToSeconds(self.end_pos)
end

function ChartAudioMixer:release()
	for _, entry in pairs(self.decoder_to_entry) do
		entry.decoder:release()
	end
	if self.dummy_decoder then
		self.dummy_decoder:release()
	end
end

---@param dst {[integer]: number}
---@param src {[integer]: integer}
---@param size integer
local function add_buffer_float(dst, src, size)
	---@type {[integer]: integer}
	local src_ptr = ffi.cast("int16_t*", src)

	for i = 0, size - 1 do
		dst[i] = dst[i] + src_ptr[i]
	end
end

---@param dst {[integer]: integer}
---@param src {[integer]: number}
---@param size integer
local function apply_mix(dst, src, size)
	---@type {[integer]: integer}
	local dst_ptr = ffi.cast("int16_t*", dst)

	for i = 0, size - 1 do
		local val = src[i]
		if val > 32767 then
			dst_ptr[i] = 32767
		elseif val < -32768 then
			dst_ptr[i] = -32768
		else
			dst_ptr[i] = val
		end
	end
end

---@param buf ffi.cdata*
---@param len integer
---@return integer
function ChartAudioMixer:getData(buf, len)
	len = self:floorBytes(len)

	if self.empty then
		ffi.fill(buf, len, 0)
		self.position = self.position + len
		return len
	end

	local samples = len / 2

	if self.dec_buf_len < len then
		self.dec_buf_len = len
		self.dec_buf = ffi.new("int16_t[?]", samples)
		self.mix_buf = ffi.new("float[?]", samples)
	end

	local dec_buf = self.dec_buf
	local mix_buf = self.mix_buf

	ffi.fill(mix_buf, samples * 4, 0)

	local pos = self.position

	-- 1. Remove sounds that ended before the current buffer
	while self.next_to_remove and self.next_to_remove.key.entry.end_pos < pos do
		self.active_sounds[self.next_to_remove.key.entry] = nil
		self.next_to_remove = self.next_to_remove:next()
	end

	-- 2. Add sounds that start before the end of the current buffer
	while self.next_to_add and self.next_to_add.key.entry.start_pos < pos + len do
		self.active_sounds[self.next_to_add.key.entry] = true
		self.next_to_add = self.next_to_add:next()
	end

	-- 3. Mix all active sounds
	for entry in pairs(self.active_sounds) do
		local start_pos = entry.start_pos
		local end_pos = entry.end_pos

		-- Double check if the sound is indeed active in this buffer
		if end_pos < pos then
			-- It should have been removed by step 1, but might be here due to setPosition or timing
			self.active_sounds[entry] = nil
		else
			local need_bytes = math.min(pos + len, end_pos) - math.max(pos, start_pos)
			local offset = math.max(start_pos - pos, 0)
			offset = offset / 2

			if need_bytes > 0 then
				local sound_pos = math.max(pos - start_pos, 0)
				if sound_pos ~= entry.decoder:getBytesPosition() then
					entry.decoder:setBytesPosition(sound_pos)
				end

				local bytes = entry.decoder:getData(dec_buf, need_bytes)
				add_buffer_float(mix_buf + offset, dec_buf, bytes / 2)
			end
		end
	end

	apply_mix(buf, mix_buf, samples)

	self.position = self.position + len

	return len
end

---@param bytes integer
---@return integer
function ChartAudioMixer:floorBytes(bytes)
	local mul = self.channels * self.bytes_per_sample
	return math.floor(bytes / mul) * mul
end

---@return number
function ChartAudioMixer:getPosition()
	return self:bytesToSeconds(self.position)
end

---@param pos number
function ChartAudioMixer:setPosition(pos)
	local new_pos = self:secondsToBytes(pos)
	if new_pos ~= self.position then
		self.position = new_pos
		self:resetActiveSet()
	end
end

---@return integer
function ChartAudioMixer:getBytesDuration()
	return self.end_pos - self.start_pos
end

---@return integer
function ChartAudioMixer:getSamplesDuration()
	local mul = self.channels * self.bytes_per_sample
	return self:getBytesDuration() / mul
end

---@param pos integer
---@return number
function ChartAudioMixer:bytesToSeconds(pos)
	return pos / (self.sample_rate * self.channels * self.bytes_per_sample)
end

---@param pos number
---@return integer
function ChartAudioMixer:secondsToBytes(pos)
	return math.floor(pos * self.sample_rate) * self.channels * self.bytes_per_sample
end

---@return integer
function ChartAudioMixer:getSampleRate()
	return self.sample_rate
end

---@return integer
function ChartAudioMixer:getChannelCount()
	return self.channels
end

---@return integer
function ChartAudioMixer:getBytesPerSample()
	return self.bytes_per_sample
end

return ChartAudioMixer
