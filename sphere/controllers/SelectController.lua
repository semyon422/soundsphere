local Class					= require("aqua.util.Class")

local SelectController = Class:new()

SelectController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel
	local selectModel = self.gameController.selectModel
	local previewModel = self.gameController.previewModel

	self.gameController:writeConfigs()

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SelectView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	view:load()
end

SelectController.unload = function(self)
	self.gameController.noteSkinModel:load()
	self.gameController.previewModel:unload()
	self.view:unload()
	self.gameController:writeConfigs()
end

SelectController.update = function(self, dt)
	self.gameController.previewModel:update(dt)
	self.gameController.selectModel:update()
	self.view:update(dt)
end

SelectController.draw = function(self)
	self.view:draw()
end

SelectController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setTheme" then
		self.themeModel:setDefaultTheme(event.theme)
	elseif event.name == "scrollCollection" then
		self.gameController.selectModel:scrollCollection(event.direction)
	elseif event.name == "scrollNoteChartSet" then
		self.gameController.selectModel:scrollNoteChartSet(event.direction)
	elseif event.name == "scrollNoteChart" then
		self.gameController.selectModel:scrollNoteChart(event.direction)
	elseif event.name == "scrollScore" then
		self.gameController.selectModel:scrollScore(event.direction)
	elseif event.name == "scrollRandom" then
		self.gameController.selectModel:scrollRandom()
	elseif event.name == "setSortFunction" then
		self.gameController.selectModel:setSortFunction(event.sortFunction)
	elseif event.name == "scrollSortFunction" then
		self.gameController.selectModel:scrollSortFunction(event.delta)
	elseif event.name == "setSearchString" then
		self.gameController.searchModel:setSearchString(event.text)
	elseif event.name == "changeScreen" then
		if event.screenName == "Modifier" then
			self:switchModifierController()
		elseif event.screenName == "NoteSkin" then
			self:switchNoteSkinController()
		elseif event.screenName == "Input" then
			self:switchInputController()
		elseif event.screenName == "Settings" then
			self:switchSettingsController()
		elseif event.screenName == "Result" then
			self:switchResultController()
		end
	elseif event.name == "changeSearchMode" then
		self.gameController.selectModel:changeSearchMode()
	elseif event.name == "changeCollapse" then
		self.gameController.selectModel:changeCollapse()
	elseif event.name == "pullNoteChartSet" then
		self.gameController.selectModel:debouncePullNoteChartSet()
	elseif event.name == "playNoteChart" then
		self:playNoteChart()
	elseif event.name == "loadModifiedNoteChart" then
		self:loadModifiedNoteChart()
	elseif event.name == "unloadModifiedNoteChart" then
		self:unloadModifiedNoteChart()
	elseif event.name == "resetModifiedNoteChart" then
		self:resetModifiedNoteChart()
	elseif event.name == "setNoteSkin" then
		self.gameController.noteSkinModel:setDefaultNoteSkin(event.noteSkin)
	elseif event.name == "quickLogin" then
		self.gameController.onlineModel.authManager:quickLogin()
	elseif event.name == "openDirectory" then
		local selectModel = self.gameController.selectModel
		local path = selectModel.noteChartItem.path:match("^(.+)/.-$")
		local mountPath = self.gameController.mountModel:getRealPath(path)
		local realPath =
			mountPath or
			love.filesystem.getSource() .. "/" .. path
		love.system.openURL("file://" .. realPath)
	elseif event.name == "updateCache" then
		local selectModel = self.gameController.selectModel
		local path = selectModel.noteChartItem.path:match("^(.+)/.-$")
		self.gameController.cacheModel:startUpdate(path, event.force)
	elseif event.name == "updateCacheCollection" then
		local state = self.gameController.cacheModel.cacheUpdater.state
		if state == 0 or state == 3 then
			self.gameController.cacheModel:startUpdate(event.collection.path, event.force)
		else
			self.gameController.cacheModel:stopUpdate()
		end
	elseif event.name == "calculateTopScores" then
		self.gameController.scoreModel:asyncCalculateTopScores()
	elseif event.name == "setInputBinding" then
		self.gameController.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "searchOsudirect" then
		self.gameController.osudirectModel:searchDebounce()
	elseif event.name == "osudirectBeatmap" then
		local osudirectModel = self.gameController.osudirectModel
		osudirectModel:setBeatmap(event.beatmap)
		local backgroundUrl = self.gameController.osudirectModel:getBackgroundUrl()
		local previewUrl = self.gameController.osudirectModel:getPreviewUrl()
		self.gameController.backgroundModel:loadBackgroundDebounce(backgroundUrl)
		self.gameController.previewModel:loadPreviewDebounce(previewUrl)
	elseif event.name == "downloadBeatmapSet" then
		self.gameController.osudirectModel:downloadBeatmapSet()
	elseif event.name == "setOsudirectSearchString" then
		self.gameController.osudirectModel:setSearchString(event.text)
	elseif event.name == "deleteNoteChart" then
	elseif event.name == "deleteNoteChartSet" then
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local modifierModel = self.gameController.modifierModel

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
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	local ModifierController = require("sphere.controllers.ModifierController")
	local modifierController = ModifierController:new()
	modifierController.selectController = self
	modifierController.gameController = self.gameController
	return self.gameController.screenManager:set(modifierController)
end

SelectController.switchNoteSkinController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	self:resetModifiedNoteChart()

	local NoteSkinController = require("sphere.controllers.NoteSkinController")
	local noteSkinController = NoteSkinController:new()
	noteSkinController.selectController = self
	noteSkinController.gameController = self.gameController
	return self.gameController.screenManager:set(noteSkinController)
end

SelectController.switchInputController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	self:resetModifiedNoteChart()

	local InputController = require("sphere.controllers.InputController")
	local inputController = InputController:new()
	inputController.selectController = self
	inputController.gameController = self.gameController
	return self.gameController.screenManager:set(inputController)
end

SelectController.switchSettingsController = function(self)
	local SettingsController = require("sphere.controllers.SettingsController")
	local settingsController = SettingsController:new()
	settingsController.selectController = self
	settingsController.gameController = self.gameController
	return self.gameController.screenManager:set(settingsController)
end

SelectController.switchResultController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	local selectModel = self.gameController.selectModel
	local scoreItemIndex = selectModel.scoreItemIndex
	local scoreItem = selectModel.scoreItem
	if not scoreItem then
		return
	end

	local ResultController = require("sphere.controllers.ResultController")
	local resultController = ResultController:new()
	resultController.selectController = self
	resultController.gameController = self.gameController
	resultController:replayNoteChart("result", scoreItem, scoreItemIndex)

	return self.gameController.screenManager:set(resultController)
end

SelectController.playNoteChart = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	local GameplayController = require("sphere.controllers.GameplayController")
	local gameplayController = GameplayController:new()
	gameplayController.selectController = self
	gameplayController.gameController = self.gameController
	return self.gameController.screenManager:set(gameplayController)
end

return SelectController
