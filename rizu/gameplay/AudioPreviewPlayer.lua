local class = require("class")
local AudioPreview = require("rizu.gameplay.AudioPreview")
local ResourceFinder = require("rizu.files.ResourceFinder")
local LoveFilesystem = require("fs.LoveFilesystem")
local bass = require("bass")
local bass_flags = require("bass.flags")
local path_util = require("path_util")
local ffi = require("ffi")

---@class rizu.gameplay.AudioPreviewPlayer
---@operator call: rizu.gameplay.AudioPreviewPlayer
local AudioPreviewPlayer = class()

function AudioPreviewPlayer:new(configModel)
	self.configModel = configModel
	---@type rizu.gameplay.AudioPreview?
	self.preview = nil
	self.chart_dir = ""
	self.last_time = -1
	self.rate = 1
	self.volume = 1
	---@type {[integer]: {start_time: number, duration: number, sample_index: integer}}
	self.active_channels = {}
	---@type {[integer]: integer}
	self.sample_handles = {}
	
	self.info = ffi.new("BASS_CHANNELINFO[1]")
	self.fs = LoveFilesystem()
end

---@param preview_data string
---@param chart_dir string
function AudioPreviewPlayer:load(preview_data, chart_dir)
	self:stop()
	
	local preview = AudioPreview()
	preview:decode(preview_data)
	self.preview = preview
	
	self.chart_dir = chart_dir
	self.finder = ResourceFinder(self.fs)
	self.finder:addPath(chart_dir)
	self.last_time = -1
end

---@param index integer
---@return integer
function AudioPreviewPlayer:getSample(index)
	if self.sample_handles[index] then
		return self.sample_handles[index]
	end

	local path = self.preview.samples[index + 1]
	local full_path = self.finder:findFile(path, "audio")
	if not full_path then
		return 0
	end

	local content = love.filesystem.read(full_path)
	if not content then
		return 0
	end

	-- BASS_SAMPLE_FLOAT = 256
	local handle = bass.BASS_SampleLoad(true, content, 0, #content, 64, bass_flags.BASS_SAMPLE_FLOAT)
	if handle == 0 then
		print("BASS_SampleLoad failed: " .. bass.BASS_ErrorGetCode())
		return 0
	end
	
	self.sample_handles[index] = handle
	return handle
end

---@param event rizu.gameplay.AudioPreviewEvent
---@param offset number?
function AudioPreviewPlayer:playEvent(event, offset)
	local sample = self:getSample(event.sample_index)
	if sample == 0 then
		return
	end

	local channel = bass.BASS_SampleGetChannel(sample, 0)
	if channel == 0 then
		return
	end

	bass.BASS_ChannelSetAttribute(channel, bass_flags.BASS_ATTRIB_VOL, event.volume * self.volume)
	
	if bass.BASS_ChannelGetInfo(channel, self.info) ~= 0 then
		bass.BASS_ChannelSetAttribute(channel, bass_flags.BASS_ATTRIB_FREQ, self.info[0].freq * self.rate)
	end

	if offset and offset > 0 then
		local bytes = bass.BASS_ChannelSeconds2Bytes(channel, offset)
		bass.BASS_ChannelSetPosition(channel, bytes, bass_flags.BASS_POS_BYTE)
	end

	if bass.BASS_ChannelPlay(channel, 0) ~= 0 then
		self.active_channels[channel] = {
			start_time = event.time,
			duration = event.duration,
			sample_index = event.sample_index
		}
	end
end

---@param time number
function AudioPreviewPlayer:update(time)
	if not self.preview then
		return
	end

	if self.last_time < time then
		-- This is O(N) but the preview usually has a limited number of events
		-- and we only check events in the current time window.
		for _, event in ipairs(self.preview.events) do
			if event.time > self.last_time and event.time <= time then
				self:playEvent(event)
			end
		end
	end
	self.last_time = time

	-- Clean up active channels
	for channel, data in pairs(self.active_channels) do
		if bass.BASS_ChannelIsActive(channel) == bass_flags.BASS_ACTIVE_STOPPED then
			self.active_channels[channel] = nil
		end
	end
end

---@param time number
function AudioPreviewPlayer:seek(time)
	self:stopChannels()
	self.last_time = time

	if not self.preview then
		return
	end

	for _, event in ipairs(self.preview.events) do
		if event.time <= time and event.time + event.duration > time then
			self:playEvent(event, time - event.time)
		end
	end
end

function AudioPreviewPlayer:stopChannels()
	for channel, _ in pairs(self.active_channels) do
		bass.BASS_ChannelStop(channel)
	end
	self.active_channels = {}
end

function AudioPreviewPlayer:pause()
	for channel, _ in pairs(self.active_channels) do
		bass.BASS_ChannelPause(channel)
	end
end

function AudioPreviewPlayer:resume()
	for channel, _ in pairs(self.active_channels) do
		-- Only resume if it was playing/paused, not stopped
		if bass.BASS_ChannelIsActive(channel) ~= bass_flags.BASS_ACTIVE_STOPPED then
			bass.BASS_ChannelPlay(channel, 0)
		end
	end
end

function AudioPreviewPlayer:stop()
	self:stopChannels()
	for _, handle in pairs(self.sample_handles) do
		bass.BASS_SampleFree(handle)
	end
	self.sample_handles = {}
	self.preview = nil
end

---@param rate number
function AudioPreviewPlayer:setRate(rate)
	self.rate = rate
	for channel, _ in pairs(self.active_channels) do
		if bass.BASS_ChannelGetInfo(channel, self.info) ~= 0 then
			bass.BASS_ChannelSetAttribute(channel, bass_flags.BASS_ATTRIB_FREQ, self.info[0].freq * rate)
		end
	end
end

---@param volume number
function AudioPreviewPlayer:setVolume(volume)
	self.volume = volume
	-- We don't have per-event volume stored in active_channels easily,
	-- but we could re-apply if needed. 
	-- For simplicity, let's just assume master volume changes are rare during preview.
end

return AudioPreviewPlayer
