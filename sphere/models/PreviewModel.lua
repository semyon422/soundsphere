local Class = require("Class")
local delay = require("delay")
local thread = require("thread")

local PreviewModel = Class:new()

PreviewModel.load = function(self)
	self.noteChartDataEntryId = 0
	self.audioPath = ""
	self.previewTime = 0
	self.volume = 0
	self.pitch = 1
end

PreviewModel.setAudioPathPreview = function(self, audioPath, previewTime)
	if self.audioPath ~= audioPath or not self.audio then
		self.audioPath = audioPath
		self.previewTime = previewTime
		self:loadPreviewDebounce()
	end
end

PreviewModel.update = function(self)
	local settings = self.configModel.configs.settings
	local muteOnUnfocus = settings.miscellaneous.muteOnUnfocus

	local audio = self.audio
	if not audio then
		return
	end
	if not audio:isPlaying() and love.window.hasFocus() then
		audio:seek(self.position or 0)
		audio:play()
	elseif audio:isPlaying() and not love.window.hasFocus() and  muteOnUnfocus then
		audio:pause()
	end

	local volumeConfig = settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		audio:setVolume(volume)
		self.volume = volume
	end

	local timeRate = self.modifierModel.state.timeRate
	if self.pitch ~= timeRate then
		audio:setPitch(timeRate)
		self.pitch = timeRate
	end
end

PreviewModel.loadPreviewDebounce = function(self, audioPath, previewTime)
	self.audioPath = audioPath or self.audioPath
	self.previewTime = previewTime or self.previewTime
	delay.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

local loadingPreview
PreviewModel.loadPreview = function(self)
	if loadingPreview then
		return
	end
	loadingPreview = true

	local path = self.audioPath
	local position = self.previewTime

	if not path then
		loadingPreview = false
		return self:stop()
	end

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info then
			loadingPreview = false
			return self:stop()
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
	if path ~= self.audioPath then
		return self:loadPreview()
	end

	if not audio then
		return
	end

	self.audio = audio
	self.path = path
	self.position = position

	local timeRate = self.modifierModel.state.timeRate
	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	audio:seek(position or 0)
	audio:setVolume(volume)
	audio:setPitch(timeRate)
	audio:play()
	self.volume = volume
end

PreviewModel.stop = function(self)
	if not self.audio then
		return
	end
	self.audio:stop()
	self.audio:release()
	self.audio = nil
end

local loadHttp = thread.async(function(url)
	local https = require("ssl.https")
	local body = https.request(url)
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

PreviewModel.loadAudio = function(self, path, type)
	local source
	if type == "http" then
		source = loadHttp(path)
	else
		source = loadAudio(path)
	end
	return source
end

return PreviewModel
