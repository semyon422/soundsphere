local Class = require("aqua.util.Class")
local AudioFactory	= require("aqua.audio.AudioFactory")
local tween				= require("tween")

local PreviewModel = Class:new()

PreviewModel.construct = function(self)
	self.loadable = 0
end

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
	local selectModel = self.selectModel

	local noteChartItem = selectModel.noteChartItem
	if not noteChartItem then
		return
	end

	local directoryPath = noteChartItem.path:match("^(.+)/(.-)$") or ""
	local audioPath = noteChartItem.audioPath

	if audioPath and audioPath ~= "" then
		return directoryPath .. "/" .. audioPath, noteChartItem.previewTime
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
