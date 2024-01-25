local class = require("class")
local delay = require("delay")
local thread = require("thread")

---@class sphere.PreviewModel
---@operator call: sphere.PreviewModel
local PreviewModel = class()

---@param configModel sphere.ConfigModel
function PreviewModel:new(configModel)
	self.configModel = configModel
end

function PreviewModel:load()
	self.audio_path = ""
	self.preview_time = 0
	self.volume = 0
	self.pitch = 1
	self.targetPitch = 1
end

---@param audio_path string?
---@param preview_time number?
function PreviewModel:setAudioPathPreview(audio_path, preview_time)
	if self.audio_path ~= audio_path or not self.audio then
		self.audio_path = audio_path
		self.preview_time = preview_time
		self:loadPreviewDebounce()
	end
end

function PreviewModel:update()
	local settings = self.configModel.configs.settings
	local muteOnUnfocus = settings.miscellaneous.muteOnUnfocus

	local audio = self.audio
	if not audio then
		return
	end
	if not audio:isPlaying() and love.window.hasFocus() then
		audio:seek(self.position or 0)
		audio:play()
	elseif audio:isPlaying() and not love.window.hasFocus() and muteOnUnfocus then
		audio:pause()
	end

	local volumeConfig = settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		audio:setVolume(volume)
		self.volume = volume
	end

	local timeRate = self.targetPitch
	if self.pitch ~= timeRate then
		audio:setPitch(timeRate)
		self.pitch = timeRate
	end
end

---@param pitch number
function PreviewModel:setPitch(pitch)
	self.targetPitch = pitch
end

---@param audio_path string?
---@param preview_time number?
function PreviewModel:loadPreviewDebounce(audio_path, preview_time)
	self.audio_path = audio_path or self.audio_path
	self.preview_time = preview_time or self.preview_time
	delay.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

local loadingPreview
function PreviewModel:loadPreview()
	if loadingPreview then
		return
	end
	loadingPreview = true

	local path = self.audio_path
	local position = self.preview_time

	if not path then
		loadingPreview = false
		self:stop()
		return
	end

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info then
			loadingPreview = false
			self:stop()
			return
		end
	end

	if self.audio then
		if self.path ~= path then
			self:stop()
		else
			loadingPreview = false
			return
		end
	end

	local audio
	if path:find("^http") then
		audio = self:loadAudio(path, "http")
	else
		audio = self:loadAudio(path)
	end

	loadingPreview = false
	if path ~= self.audio_path then
		self:loadPreview()
		return
	end

	if not audio then
		return
	end

	self.audio = audio
	self.path = path
	self.position = position

	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	audio:seek(position or 0)
	audio:setVolume(volume)
	audio:setPitch(self.pitch)
	audio:play()
	self.volume = volume
end

function PreviewModel:stop()
	if not self.audio then
		return
	end
	self.audio:stop()
	self.audio:release()
	self.audio = nil
end

local loadHttp = thread.async(function(url)
	local http = require("http")
	local body = http.request(url)
	if not body then
		return
	end

	require("love.filesystem")
	require("love.audio")
	require("love.sound")
	local fileData = love.filesystem.newFileData(body, url:match("^.+/(.-)$"))
	local status, source = pcall(love.audio.newSource, fileData, "static")
	if status then
		return source
	end
end)

local loadAudio = thread.async(function(path)
	require("love.filesystem")
	require("love.audio")
	require("love.sound")

	local info = love.filesystem.getInfo(path)
	if not info then
		return
	end

	local status, source = pcall(love.audio.newSource, path, "stream")
	if status then
		return source
	end
end)

---@param path string
---@param type string?
---@return love.Source?
function PreviewModel:loadAudio(path, type)
	local source
	if type == "http" then
		source = loadHttp(path)
	else
		source = loadAudio(path)
	end
	return source
end

return PreviewModel
