local IChartAudioSource = require("rizu.engine.audio.IChartAudioSource")
local bit = require("bit")
local bass = require("bass")
local bass_assert = require("bass.assert")
local bass_mix = require("bass.mix")
local bass_flags = require("bass.flags")

---@class rizu.BassChartAudioSource: rizu.IChartAudioSource
---@operator call: rizu.BassChartAudioSource
local BassChartAudioSource = IChartAudioSource + {}

---@param channel integer
---@return number
local function get_length(channel)
	local length = bass.BASS_ChannelGetLength(channel, 0)
	bass_assert(length >= 0)
	length = bass.BASS_ChannelBytes2Seconds(channel, length)
	bass_assert(length >= 0)
	return length
end

---@param sounds rizu.ChartAudioSound[]
---@param resources {[string]: string}
function BassChartAudioSource:new(sounds, resources)
	local mix_chan = bass_mix.BASS_Mixer_StreamCreate(44100, 2, 0)
	self.channel = mix_chan
	bass_assert(mix_chan ~= 0)

	--- Keep files in memory to prevent freeing them
	---@type string[]
	self.data = {}

	self.start_time = sounds[1] and sounds[1].time or 0
	self.end_time = self.start_time

	for _, sound in ipairs(sounds) do
		self:addSound(sound, resources[sound.name])
	end
end

---@private
---@param sound rizu.ChartAudioSound
---@param data string?
function BassChartAudioSource:addSound(sound, data)
	if not data then
		return
	end

	table.insert(self.data, data)

	local dec_chan = bass.BASS_StreamCreateFile(true, data, 0, #data, bit.bor(bass_flags.BASS_STREAM_DECODE, bass_flags.BASS_STREAM_PRESCAN))
	self.end_time = math.max(self.end_time, sound.time + get_length(dec_chan))

	local ok = bass_mix.BASS_Mixer_StreamAddChannelEx(
		self.channel,
		dec_chan,
		bass_flags.BASS_STREAM_AUTOFREE,
		bass.BASS_ChannelSeconds2Bytes(self.channel, sound.time),
		0
	) == 1
	-- bass_assert(ok == 1)
end

function BassChartAudioSource:release()
	bass_assert(bass.BASS_ChannelFree(self.channel) == 1)
end

function BassChartAudioSource:play()
	bass_assert(bass.BASS_ChannelPlay(self.channel, false) == 1)
end

function BassChartAudioSource:pause()
	bass.BASS_ChannelPause(self.channel)
end

---@return boolean
function BassChartAudioSource:isPlaying()
	return bass_mix.BASS_Mixer_ChannelIsActive(self.channel) == bass_flags.BASS_ACTIVE_PLAYING
end

---@param rate number
function BassChartAudioSource:setRate(rate)
	bass.BASS_ChannelSetAttribute(self.channel, 1, self.info.freq * rate)
end

---@return number
function BassChartAudioSource:getPosition()
	local pos = bass_mix.BASS_Mixer_ChannelGetPosition(self.channel, bass_flags.BASS_POS_BYTE)
	bass_assert(pos >= 0)
	pos = bass.BASS_ChannelBytes2Seconds(self.channel, pos)
	bass_assert(pos >= 0)
	return pos
end

---@param position number
function BassChartAudioSource:setPosition(position)
	assert(position >= 0)
	local pos = bass.BASS_ChannelSeconds2Bytes(self.channel, position)
	bass_assert(pos >= 0)
	pos = bass.BASS_Mixer_ChannelSetPosition(self.channel, pos, bit.bor(bass_flags.BASS_POS_BYTE, bass_flags.BASS_POS_MIXER_RESET))
	bass_assert(pos == 1)
end

---@return number
function BassChartAudioSource:getStartTime()
	return self.start_time
end

---@return number
function BassChartAudioSource:getDuration()
	return self.end_time - self.start_time
end

---@param volume number
function BassChartAudioSource:setVolume(volume)
	bass_assert(bass.BASS_ChannelSetAttribute(self.channel, bass_flags.BASS_ATTRIB_VOL, volume) == 1)
end

return BassChartAudioSource
