local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local aquathread = require("aqua.thread")

local PreviewModel = Class:new()

PreviewModel.load = function(self)
	self.config = self.configModel.configs.select
	self.noteChartDataEntryId = 0
	self.audioPath = ""
	self.previewTime = 0
	self.volume = 0
	self.pitch = 1
end

PreviewModel.unload = function(self)
	self:stop()
end

PreviewModel.update = function(self, dt)
	local noteChartItem = self.selectModel.noteChartItem
	if noteChartItem and self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		self.noteChartDataEntryId = self.config.noteChartDataEntryId
		local audioPath, previewTime = noteChartItem:getAudioPathPreview()
		if self.audioPath ~= audioPath then
			self.audioPath = audioPath
			self.previewTime = previewTime
			self:loadPreviewDebounce()
		end
	end

	local audio = self.audio
	if not audio then
		return
	end
	if not audio:isPlaying() then
		audio:seek(self.position or 0)
		audio:play()
	end

	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	if self.volume ~= volume then
		audio:setVolume(volume)
		self.volume = volume
	end

	local baseTimeRate = self.rhythmModel.timeEngine.baseTimeRate
	if self.pitch ~= baseTimeRate then
		audio:setPitch(baseTimeRate)
		self.pitch = baseTimeRate
	end
end

PreviewModel.loadPreviewDebounce = function(self, audioPath, previewTime)
	self.audioPath = audioPath or self.audioPath
	self.previewTime = previewTime or self.previewTime
	aquatimer.debounce(self, "loadDebounce", 0.1, self.loadPreview, self)
end

PreviewModel.loadPreview = function(self)
	local path = self.audioPath
	local position = self.previewTime

	if not path then
		return self:stop()
	end

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info then
			return self:stop()
		end
	end

	if self.audio then
		if self.path ~= path then
			self:stop()
		else
			return
		end
	end

	local audio
	if path:find("^http") then
		audio = self:loadAudio(path, "http")
	else
		audio = self:loadAudio(path)
	end

	if path ~= self.audioPath then
		return self:loadPreview()
	end

	if not audio then
		return
	end

	self.audio = audio
	self.path = path
	self.position = position

	local baseTimeRate = self.rhythmModel.timeEngine.baseTimeRate
	local volumeConfig = self.configModel.configs.settings.audio.volume
	local volume = volumeConfig.master * volumeConfig.music
	audio:seek(position or 0)
	audio:setVolume(volume)
	audio:setPitch(baseTimeRate)
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

local loadHttp = aquathread.async(function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end

	require("love.filesystem")
	require("love.audio")
	require("love.sound")
	local fileData = love.filesystem.newFileData(response.body, url:match("^.+/(.-)$"))
	local status, source = pcall(love.audio.newSource, fileData, "static")
	if status then
		return source
	end
end)

local loadAudio = aquathread.async(function(path)
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
