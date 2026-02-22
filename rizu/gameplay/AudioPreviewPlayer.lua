local class = require("class")
local ThreadRemote = require("aqua.threadremote.ThreadRemote")
local BufferedPreviewSoundDecoder = require("rizu.engine.audio.BufferedPreviewSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local LoveFilesystem = require("fs.LoveFilesystem")
local thread = require("thread")

---@class rizu.gameplay.AudioPreviewPlayer
---@operator call: rizu.gameplay.AudioPreviewPlayer
local AudioPreviewPlayer = class()

function AudioPreviewPlayer:new(configModel)
	self.configModel = configModel
	self.fs = LoveFilesystem()
	self.thread = nil
	self.buffered_decoder = nil
	---@type rizu.BassChartAudioSource?
	self.audio_source = nil
	self.volume = 1
	self.rate = 1
	self.is_playing = false
	self.last_time = 0
	self.pending_seek = nil
end

---@param preview_data string
---@param chart_dir string
function AudioPreviewPlayer:load(preview_data, chart_dir)
	self:stop()
	self.pending_seek = nil

	-- Unique ID for thread remote
	local thread_id = "preview_player_" .. tostring(love.timer.getTime())
	self.thread = ThreadRemote(thread_id, {})
	
	self.thread:start(function(remote, dir, preview_data)
		local PreviewSoundDecoder = require("rizu.engine.audio.PreviewSoundDecoder")
		local AudioPreview = require("rizu.gameplay.AudioPreview")
		local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
		local LoveFilesystem = require("fs.LoveFilesystem")

		local preview = AudioPreview()
		preview:decode(preview_data)

		local fs = LoveFilesystem()
		local decoder = PreviewSoundDecoder(fs, dir, preview, function(_, path)
			return BassSoundDecoder(love.filesystem.read(path))
		end)

		return decoder
	end, chart_dir, preview_data)

	thread.coro(function()
		-- BufferedPreviewSoundDecoder(self.thread.remote) calls metadata methods
		-- which will yield and wait for thread remote update.
		local buffered = BufferedPreviewSoundDecoder(self.thread.remote)
		self.buffered_decoder = buffered
		
		self.audio_source = BassChartAudioSource(buffered)
		self.audio_source:setVolume(self.volume)
		self.audio_source:setRate(self.rate)
		
		if self.pending_seek then
			self.audio_source:setPosition(self.pending_seek)
			self.pending_seek = nil
		end

		if self.is_playing then
			self.audio_source:play()
		end
	end)()
end

function AudioPreviewPlayer:update(time)
	if self.thread then
		self.thread:update()
	end

	if not self.audio_source then
		return
	end

	-- Drift check and sync
	-- BassChartAudioSource provides getPosition() which accounts for buffer
	local stream_time = self.audio_source:getPosition()
	
	-- If time drifts more than 100ms, seek the audio source to resync.
	if math.abs(stream_time - time) > 0.1 then
		self:seek(time)
	end

	if self.is_playing then
		self.audio_source:update()
	end
end

function AudioPreviewPlayer:seek(time)
	if not self.audio_source then
		self.pending_seek = time
		return
	end
	self.audio_source:setPosition(time)
end

function AudioPreviewPlayer:pause()
	self.is_playing = false
	if self.audio_source then
		self.audio_source:pause()
	end
end

function AudioPreviewPlayer:resume()
	self.is_playing = true
	if self.audio_source then
		self.audio_source:play()
	end
end

function AudioPreviewPlayer:stop()
	self.is_playing = false
	if self.audio_source then
		self.audio_source:release()
		self.audio_source = nil
	end
	if self.buffered_decoder then
		self.buffered_decoder:release()
		self.buffered_decoder = nil
	end
	self.thread = nil
end

function AudioPreviewPlayer:setRate(rate)
	self.rate = rate
	if self.audio_source then
		self.audio_source:setRate(rate)
	end
end

function AudioPreviewPlayer:setVolume(volume)
	self.volume = volume
	if self.audio_source then
		self.audio_source:setVolume(volume)
	end
end

return AudioPreviewPlayer
