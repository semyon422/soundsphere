local Class					= require("aqua.util.Class")

local SelectController = Class:new()

SelectController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local selectModel = self.game.selectModel
	local previewModel = self.game.previewModel

	self.game:writeConfigs()

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
end

SelectController.receive = function(self, event)
	if event.name == "scrollCollection" then
		self.game.selectModel:scrollCollection(event.direction)
	elseif event.name == "scrollNoteChartSet" then
		self.game.selectModel:scrollNoteChartSet(event.direction)
	elseif event.name == "scrollNoteChart" then
		self.game.selectModel:scrollNoteChart(event.direction)
	elseif event.name == "scrollScore" then
		self.game.selectModel:scrollScore(event.direction)
	elseif event.name == "scrollRandom" then
		self.game.selectModel:scrollRandom()
	elseif event.name == "setSortFunction" then
		self.game.selectModel:setSortFunction(event.sortFunction)
	elseif event.name == "scrollSortFunction" then
		self.game.selectModel:scrollSortFunction(event.delta)
	elseif event.name == "setSearchString" then
		self.game.searchModel:setSearchString(event.text)
	elseif event.name == "changeSearchMode" then
		self.game.selectModel:changeSearchMode()
	elseif event.name == "changeCollapse" then
		self.game.selectModel:changeCollapse()
	elseif event.name == "pullNoteChartSet" then
		self.game.selectModel:debouncePullNoteChartSet()
	elseif event.name == "loadModifiedNoteChart" then
		self:loadModifiedNoteChart()
	elseif event.name == "unloadModifiedNoteChart" then
		self:unloadModifiedNoteChart()
	elseif event.name == "resetModifiedNoteChart" then
		self:resetModifiedNoteChart()
	elseif event.name == "setNoteSkin" then
		self.game.noteSkinModel:setDefaultNoteSkin(event.noteSkin)
	elseif event.name == "quickLogin" then
		self.game.onlineModel.authManager:quickLogin()
	elseif event.name == "login" then
		self.game.onlineModel.authManager:login(event.email, event.password)
	elseif event.name == "openDirectory" then
		local selectModel = self.game.selectModel
		local path = selectModel.noteChartItem.path:match("^(.+)/.-$")
		local mountPath = self.game.mountModel:getRealPath(path)
		local realPath =
			mountPath or
			love.filesystem.getSource() .. "/" .. path
		love.system.openURL("file://" .. realPath)
	elseif event.name == "updateCache" then
		local selectModel = self.game.selectModel
		local path = selectModel.noteChartItem.path:match("^(.+)/.-$")
		self.game.cacheModel:startUpdate(path, event.force)
	elseif event.name == "updateCacheCollection" then
		local state = self.game.cacheModel.cacheUpdater.state
		if state == 0 or state == 3 then
			self.game.cacheModel:startUpdate(event.collection.path, event.force)
		else
			self.game.cacheModel:stopUpdate()
		end
	elseif event.name == "calculateTopScores" then
		self.game.scoreModel:asyncCalculateTopScores()
	elseif event.name == "setInputBinding" then
		self.game.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "searchOsudirect" then
		self.game.osudirectModel:searchDebounce()
	elseif event.name == "osudirectBeatmap" then
		local osudirectModel = self.game.osudirectModel
		osudirectModel:setBeatmap(event.beatmap)
		local backgroundUrl = self.game.osudirectModel:getBackgroundUrl()
		local previewUrl = self.game.osudirectModel:getPreviewUrl()
		self.game.backgroundModel:loadBackgroundDebounce(backgroundUrl)
		self.game.previewModel:loadPreviewDebounce(previewUrl)
	elseif event.name == "downloadBeatmapSet" then
		self.game.osudirectModel:downloadBeatmapSet()
	elseif event.name == "setOsudirectSearchString" then
		self.game.osudirectModel:setSearchString(event.text)
	elseif event.name == "deleteNoteChart" then
	elseif event.name == "deleteNoteChartSet" then
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

SelectController.loadModifiedNoteChart = function(self)
	if not self.noteChartModel.noteChart then
		self:resetModifiedNoteChart()
	end
end

SelectController.unloadModifiedNoteChart = function(self)
	self.noteChartModel:unloadNoteChart()
end

SelectController.checkChartExists = function(self)
	return self.game.noteChartModel:getFileInfo() ~= nil
end

return SelectController
