local class = require("class")
local ThreadRemote = require("threadremote.ThreadRemote")
local BufferedPreviewSoundDecoder = require("rizu.engine.audio.BufferedPreviewSoundDecoder")
local BassChartAudioSource = require("rizu.engine.audio.BassChartAudioSource")
local thread = require("thread")

---@class rizu.gameplay.AudioPreviewPlayer
---@operator call: rizu.gameplay.AudioPreviewPlayer
---@field pending_seek number?
local AudioPreviewPlayer = class()

AudioPreviewPlayer.volume = 1
AudioPreviewPlayer.rate = 1
AudioPreviewPlayer.is_playing = false

function AudioPreviewPlayer:new(configModel)
	self.configModel = configModel
end

---@param preview_path string
---@param chart_dir string
function AudioPreviewPlayer:load(preview_path, chart_dir)
	self:stop()
	self.pending_seek = nil

	-- Unique ID for thread remote
	local thread_id = "preview_player_" .. tostring(love.timer.getTime())
	self.thread = ThreadRemote(thread_id, {})

	self.thread:start(function(remote, dir, preview_path)
		local PreviewSoundDecoder = require("rizu.engine.audio.PreviewSoundDecoder")
		local AudioPreview = require("rizu.gameplay.AudioPreview")
		local BassSoundDecoder = require("rizu.engine.audio.BassSoundDecoder")
		local LoveFilesystem = require("fs.LoveFilesystem")
		local fs = LoveFilesystem()

		local preview_data = fs:read(preview_path)
		if not preview_data then
			error("AudioPreviewPlayer: could not read preview file " .. tostring(preview_path))
		end

		local preview = AudioPreview()
		preview:decode(preview_data)

		local decoder = PreviewSoundDecoder(fs, dir, preview, function(_, path)
			return BassSoundDecoder(fs:read(path))
		end)

		return decoder
	end, chart_dir, preview_path)

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

function AudioPreviewPlayer:update()
	if self.thread then
		self.thread:update()
	end

	if not self.audio_source then
		return
	end

	if self.is_playing then
		self.audio_source:update()
	end
end

---@param time number
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

---@param rate number
function AudioPreviewPlayer:setRate(rate)
	self.rate = rate
	if self.audio_source then
		self.audio_source:setRate(rate)
	end
end

---@param volume number
function AudioPreviewPlayer:setVolume(volume)
	self.volume = volume
	if self.audio_source then
		self.audio_source:setVolume(volume)
	end
end

return AudioPreviewPlayer
