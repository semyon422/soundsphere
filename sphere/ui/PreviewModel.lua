local class = require("class")
local delay = require("delay")
local thread = require("thread")
local audio = require("audio")

---@class sphere.PreviewModel
---@operator call: sphere.PreviewModel
local PreviewModel = class()

PreviewModel.preview_time = 0
PreviewModel.position = 0
PreviewModel.mode = "absolute"

---@param configModel sphere.ConfigModel
function PreviewModel:new(configModel)
	self.configModel = configModel
end

function PreviewModel:load()
	self.audio_path = ""
	self.volume = 0
	self.rate = 1
	self.target_rate = 1
end

---@param audio_path string?
---@param preview_time number?
---@param mode string?
function PreviewModel:setAudioPathPreview(audio_path, preview_time, mode)
	if self.audio_path ~= audio_path or not self.audio then
		self.audio_path = audio_path
		self.preview_time = preview_time
		self.mode = mode
		self:loadPreviewDebounce()
		return
	end
	if self._on_load then
		self._on_load()
		self._on_load = nil
	end
end

---@param f function
function PreviewModel:onLoad(f)
	self._on_load = f
end

function PreviewModel:update()
	local settings = self.configModel.configs.settings
	local muteOnUnfocus = settings.miscellaneous.muteOnUnfocus

	local audio = self.audio
	if not audio then
		return
	end
	if not audio:isPlaying() and love.window.hasFocus() then
		audio:seek(self.position)
		if not audio:play() then
			self.audio = nil -- invalid audio
			return
		end
	elseif audio:isPlaying() and not love.window.hasFocus() and muteOnUnfocus then
		audio:pause()
	end

	local volumeConfig = settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		audio:setVolume(volume)
		self.volume = volume
	end

	local target_rate = self.target_rate
	if self.rate ~= target_rate then
		audio:setRate(target_rate)
		self.rate = target_rate
	end
end

---@param rate number
function PreviewModel:setRate(rate)
	self.target_rate = rate
end

function PreviewModel:getTime()
	if not self.audio then
		return 0
	end
	return self.audio:getPosition()
end

function PreviewModel:loadPreviewDebounce()
	delay.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

local loadingPreview
function PreviewModel:loadPreview()
	if loadingPreview then
		return
	end
	loadingPreview = true

	local path = self.audio_path

	if not path then
		loadingPreview = false
		self:stop()
		return
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

	local position = self.preview_time
	if self.mode == "relative" then
		position = audio:getDuration() * position
	end
	position = math.max(position, 0)
	self.position = position

	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	audio:seek(position)
	audio:setVolume(volume)
	if audio.setRate then
		audio:setRate(self.rate)
	else
		audio:setPitch(self.rate)
	end
	if not audio:play() then
		self.audio = nil -- invalid audio
		return
	end
	self.volume = volume
	if self._on_load then
		self._on_load()
		self._on_load = nil
	end
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

local function loadAudio(path)
	local status, source = pcall(audio.newFileSource, path)
	if status then
		return source
	end
end

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
