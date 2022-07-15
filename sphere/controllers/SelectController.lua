local Class					= require("aqua.util.Class")

local SelectController = Class:new()

SelectController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local selectModel = self.game.selectModel
	local previewModel = self.game.previewModel

	self.game:writeConfigs()
	self.game:resetGameplayConfigs()

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	local timeEngine = self.game.rhythmModel.timeEngine
	timeEngine:resetTimeRateHandlers()
	self.game.modifierModel:apply("TimeEngineModifier")
	timeEngine:getBaseTimeRate()
end

SelectController.unload = function(self)
	self.game.noteSkinModel:load()
	self.game.previewModel:unload()
	self.game:writeConfigs()
end

SelectController.update = function(self, dt)
	self.game.previewModel:update(dt)
	self.game.selectModel:update()

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.game.baseVsync
	end

	local noteChartItem = self.game.selectModel.noteChartItem
	if self.game.selectModel:isChanged() and noteChartItem then
		local bgPath = noteChartItem:getBackgroundPath()
		local audioPath, previewTime = noteChartItem:getAudioPathPreview()
		self.game.backgroundModel:setBackgroundPath(bgPath)
		self.game.previewModel:setAudioPathPreview(audioPath, previewTime)
	end

	local osudirectModel = self.game.osudirectModel
	if osudirectModel:isChanged() then
		local backgroundUrl = osudirectModel:getBackgroundUrl()
		local previewUrl = osudirectModel:getPreviewUrl()
		self.game.backgroundModel:loadBackgroundDebounce(backgroundUrl)
		self.game.previewModel:loadPreviewDebounce(previewUrl)
	end
end

SelectController.openDirectory = function(self)
	local noteChartItem = self.game.selectModel.noteChartItem
	if not noteChartItem then
		return
	end
	local path = noteChartItem.path:match("^(.+)/.-$")
	local mountPath = self.game.mountModel:getRealPath(path)
	local realPath = mountPath or love.filesystem.getSource() .. "/" .. path
	love.system.openURL("file://" .. realPath)
end

SelectController.updateCache = function(self, force)
	local noteChartItem = self.game.selectModel.noteChartItem
	if not noteChartItem then
		return
	end
	local path = noteChartItem.path:match("^(.+)/.-$")
	self.game.cacheModel:startUpdate(path, force)
end

SelectController.updateCacheCollection = function(self, path, force)
	local state = self.game.cacheModel.cacheUpdater.state
	if state == 0 or state == 3 then
		self.game.cacheModel:startUpdate(path, force)
	else
		self.game.cacheModel:stopUpdate()
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.game.noteChartModel
	local modifierModel = self.game.modifierModel

	noteChartModel:load()
	local noteChart = noteChartModel:loadNoteChart()
	if not noteChart then
		return
	end

	modifierModel.noteChart = noteChart
	modifierModel:apply("NoteChartModifier")
end

return SelectController
