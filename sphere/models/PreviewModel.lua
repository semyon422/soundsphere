local Class = require("aqua.util.Class")
local AudioFactory	= require("aqua.audio.AudioFactory")
local aquatimer				= require("aqua.timer")

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
	if self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		local audioPath, previewTime = self:getAudioPathPreview()
		if audioPath then
			self.noteChartDataEntryId = self.config.noteChartDataEntryId
		end
		if audioPath and self.audioPath ~= audioPath then
			self.audioPath = audioPath
			self.previewTime = previewTime
			aquatimer.debounce(self, "playDebounce", 0.1, self.play, self)
		end
	end

	if self.audio and not self.audio:isPlaying() then
		self.audio:setPosition(self.position)
		self.audio:play()
	end
end

PreviewModel.getAudioPathPreview = function(self)
	local selectModel = self.selectModel

	local noteChartItem = selectModel.noteChartItem
	if not noteChartItem or not noteChartItem.path or not noteChartItem.audioPath then
		return
	end

	local directoryPath = noteChartItem.path:match("^(.+)/(.-)$") or ""
	local audioPath = noteChartItem.audioPath

	if audioPath and audioPath ~= "" then
		return directoryPath .. "/" .. audioPath, noteChartItem.previewTime
	end

	return directoryPath .. "/preview.ogg", 0
end

PreviewModel.play = function(self)
	local path = self.audioPath
	local position = self.previewTime

	local info = love.filesystem.getInfo(path)
	if not info then
		self:stop()
		return
	end
	if self.audio then
		if self.path ~= path then
			self:stop()
		else
			return
		end
	end

	local config = self.configModel.configs.settings
	local audio = AudioFactory:getAudio(path, config.audio.mode.preview)

	if not audio then
		return
	end

	self.path = path
	self.position = position
	self.audio = audio
	self.audio:setPosition(position)
	self.audio:setVolume(config.audio.volume.master * config.audio.volume.music)
	self.audio:play()
end

PreviewModel.stop = function(self)
	if self.audio then
		self.audio:stop()
		self.audio:free()
	end
	self.audio = nil
end

return PreviewModel
