local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local aquathread = require("aqua.thread")

local PreviewModel = Class:new()

PreviewModel.load = function(self)
	self.config = self.configModel.configs.select
	self.noteChartDataEntryId = 0
	self.audioPath = ""
	self.previewTime = 0
end

PreviewModel.unload = function(self)
	self:stop()
end

PreviewModel.update = function(self, dt)
	local noteChartItem = self.selectModel.noteChartItem
	if noteChartItem and self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		local audioPath, previewTime = noteChartItem:getAudioPathPreview()
		if audioPath then
			self.noteChartDataEntryId = self.config.noteChartDataEntryId
		end
		if audioPath and self.audioPath ~= audioPath then
			self.audioPath = audioPath
			self.previewTime = previewTime
			self:loadPreviewDebounce()
		end
	end

	if self.audio and not self.audio:isPlaying() then
		self.audio:seek(self.position or 0)
		self.audio:play()
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

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info then
			self:stop()
			return
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
	if not audio then
		return
	end

	self.audio = audio
	self.path = path
	self.position = position

	local volume = self.configModel.configs.settings.audio.volume
	audio:seek(position or 0)
	audio:setVolume(volume.master * volume.music)
	audio:play()
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
