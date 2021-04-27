local Class = require("aqua.util.Class")
local AudioFactory	= require("aqua.audio.AudioFactory")
local tween				= require("tween")

local PreviewModel = Class:new()

PreviewModel.construct = function(self)
	self.loadable = 0
end

PreviewModel.load = function(self)
	self.config = self.configModel:getConfig("select")
	self.noteChartDataEntryId = 0
	self.audioPath = ""
	self.previewTime = 0
end

PreviewModel.unload = function(self)
	self:stop()
end

PreviewModel.update = function(self, dt)
	if self.loadTween then
		self.loadTween:update(dt)
	end

	if self.noteChartDataEntryId ~= self.config.noteChartDataEntryId then
		self.noteChartDataEntryId = self.config.noteChartDataEntryId
		local audioPath, previewTime = self:getAudioPathPreview()
		if audioPath and self.audioPath ~= audioPath then
			self.audioPath = audioPath
			self.previewTime = previewTime
			self.loadable = 0
			self.loadTween = tween.new(0.1, self, {loadable = 1}, "inOutQuad")
		end
	end

	if self.loadable == 1 then
		self:play(self.audioPath, self.previewTime)
		self.loadable = 0
	end

	if not self.audio then return end

	if not self.audio:isPlaying() then
		self.audio:setPosition(self.position)
		self.audio:play()
	end
end

PreviewModel.getAudioPathPreview = function(self)
	local config = self.config

	local noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(config.noteChartSetEntryId)
	local noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntryById(config.noteChartDataEntryId)

	if not noteChartSetEntry then
		return
	end

	local directoryPath = noteChartSetEntry.path
	local audioPath = noteChartDataEntry.audioPath

	if audioPath and audioPath ~= "" then
		return directoryPath .. "/" .. audioPath, noteChartDataEntry.previewTime
	end

	return directoryPath .. "/preview.ogg", 0
end

PreviewModel.play = function(self, path, position)
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

	local config = self.configModel:getConfig("settings")
	local audio = AudioFactory:getAudio(path, config.audio.previewAudioMode)

	if not audio then
		return
	end

	self.path = path
	self.position = position
	self.audio = audio
	self.audio:setPosition(position)
	self.audio:setVolume(config.audio.volumeGlobal * config.audio.volumeMusic)
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
