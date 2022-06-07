local Class					= require("aqua.util.Class")

local SelectController = Class:new()

SelectController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local themeModel = self.game.themeModel
	local selectModel = self.game.selectModel
	local previewModel = self.game.previewModel

	self.game:writeConfigs()

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SelectView")
	self.view = view

	view.controller = self
	view.game = self.game

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	view:load()

	local timeEngine = self.game.rhythmModel.timeEngine
	timeEngine:resetTimeRateHandlers()
	self.game.modifierModel:apply("TimeEngineModifier")
	timeEngine:getBaseTimeRate()
end

SelectController.unload = function(self)
	self.game.noteSkinModel:load()
	self.game.previewModel:unload()
	self.view:unload()
	self.game:writeConfigs()
end

SelectController.update = function(self, dt)
	self.game.previewModel:update(dt)
	self.game.selectModel:update()
	self.view:update(dt)

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.game.baseVsync
	end
end

SelectController.draw = function(self)
	self.view:draw()
end

SelectController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setTheme" then
		self.themeModel:setDefaultTheme(event.theme)
	elseif event.name == "scrollCollection" then
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
	elseif event.name == "changeScreen" then
		if event.screenName == "Modifier" then
			self:switchModifierController()
		elseif event.screenName == "Result" then
			self:switchResultController()
		end
	elseif event.name == "changeSearchMode" then
		self.game.selectModel:changeSearchMode()
	elseif event.name == "changeCollapse" then
		self.game.selectModel:changeCollapse()
	elseif event.name == "pullNoteChartSet" then
		self.game.selectModel:debouncePullNoteChartSet()
	elseif event.name == "playNoteChart" then
		self:playNoteChart()
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

SelectController.switchModifierController = function(self)
	if not self.game.noteChartModel:getFileInfo() then
		return
	end

	return self.game.screenManager:set(self.game.modifierController)
end

SelectController.switchResultController = function(self)
	if not self.game.noteChartModel:getFileInfo() then
		return
	end

	local selectModel = self.game.selectModel
	local scoreItemIndex = selectModel.scoreItemIndex
	local scoreItem = selectModel.scoreItem
	if not scoreItem then
		return
	end

	local resultController = self.game.resultController
	resultController:replayNoteChart("result", scoreItem, scoreItemIndex)

	return self.game.screenManager:set(resultController)
end

SelectController.playNoteChart = function(self)
	if not self.game.noteChartModel:getFileInfo() then
		return
	end

	return self.game.screenManager:set(self.game.gameplayController)
end

return SelectController
