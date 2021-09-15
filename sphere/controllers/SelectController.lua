local Class					= require("aqua.util.Class")

local SelectController = Class:new()

SelectController.load = function(self)
	local modifierModel = self.gameController.modifierModel
	local noteSkinModel = self.gameController.noteSkinModel
	local noteChartModel = self.gameController.noteChartModel
	local inputModel = self.gameController.inputModel
	local cacheModel = self.gameController.cacheModel
	local themeModel = self.gameController.themeModel
	local configModel = self.gameController.configModel
	local mountModel = self.gameController.mountModel
	local scoreModel = self.gameController.scoreModel
	local onlineModel = self.gameController.onlineModel
	local difficultyModel = self.gameController.difficultyModel
	local backgroundModel = self.gameController.backgroundModel
	local collectionModel = self.gameController.collectionModel
	local noteChartSetLibraryModel = self.gameController.noteChartSetLibraryModel
	local noteChartLibraryModel = self.gameController.noteChartLibraryModel
	local scoreLibraryModel = self.gameController.scoreLibraryModel
	local sortModel = self.gameController.sortModel
	local searchModel = self.gameController.searchModel
	local selectModel = self.gameController.selectModel
	local previewModel = self.gameController.previewModel
	local updateModel = self.gameController.updateModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SelectView")
	self.view = view

	noteChartSetLibraryModel.cacheModel = cacheModel
	noteChartSetLibraryModel.collectionModel = collectionModel
	noteChartSetLibraryModel.searchModel = searchModel
	noteChartLibraryModel.cacheModel = cacheModel
	noteChartLibraryModel.searchModel = searchModel
	scoreLibraryModel.scoreModel = scoreModel
	selectModel.collectionModel = collectionModel
	selectModel.configModel = configModel
	selectModel.searchModel = searchModel
	selectModel.noteChartSetLibraryModel = noteChartSetLibraryModel
	selectModel.noteChartLibraryModel = noteChartLibraryModel
	selectModel.sortModel = sortModel
	selectModel.scoreLibraryModel = scoreLibraryModel
	previewModel.configModel = configModel
	previewModel.cacheModel = cacheModel
	searchModel.scoreModel = scoreModel

	view.themeModel = themeModel
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel
	view.cacheModel = cacheModel
	view.configModel = configModel
	view.mountModel = mountModel
	view.scoreModel = scoreModel
	view.onlineModel = onlineModel
	view.backgroundModel = backgroundModel
	view.updateModel = updateModel

	view.controller = self
	view.noteChartSetLibraryModel = noteChartSetLibraryModel
	view.noteChartLibraryModel = noteChartLibraryModel
	view.scoreLibraryModel = scoreLibraryModel
	view.sortModel = sortModel
	view.searchModel = searchModel
	view.selectModel = selectModel

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	view:load()
end

SelectController.unload = function(self)
	self.gameController.previewModel:unload()
	self.view:unload()
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
	elseif event.name == "scrollNoteChartSet" then
		self.gameController.selectModel:scrollNoteChartSet(event.direction)
	elseif event.name == "scrollNoteChart" then
		self.gameController.selectModel:scrollNoteChart(event.direction)
	elseif event.name == "scrollScore" then
		self.gameController.selectModel:scrollScore(event.direction)
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
		elseif event.screenName == "Collection" then
			self:switchCollectionController()
		elseif event.screenName == "Result" then
			self:switchResultController()
		end
	elseif event.name == "changeSearchMode" then
		self.gameController.selectModel:changeSearchMode()
	elseif event.name == "changeCollapse" then
		self.gameController.selectModel:changeCollapse()
	elseif event.name == "playNoteChart" then
		self:playNoteChart()
	elseif event.name == "loadModifiedNoteChart" then
		self:loadModifiedNoteChart()
	elseif event.name == "unloadModifiedNoteChart" then
		self:unloadModifiedNoteChart()
	elseif event.name == "resetModifiedNoteChart" then
		self:resetModifiedNoteChart()
	elseif event.name == "quickLogin" then
		self.gameController.onlineModel:quickLogin(self.gameController.configModel:getConfig("online").quick_login_key)
	elseif event.name == "openDirectory" then
		local selectModel = self.gameController.selectModel
		local path = selectModel.noteChartItem.noteChartEntry.path:match("^(.+)/.-$")
		local mountPath = self.gameController.mountModel:getRealPath(path)
		local realPath =
			mountPath or
			love.filesystem.getSource() .. "/" .. path
		love.system.openURL("file://" .. realPath)
	elseif event.name == "updateCache" then
		local selectModel = self.gameController.selectModel
		local path = selectModel.noteChartItem.noteChartEntry.path:match("^(.+)/.-$")
		self.gameController.cacheModel:startUpdate(path, event.force)
	elseif event.name == "deleteNoteChart" then
	elseif event.name == "deleteNoteChartSet" then
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local modifierModel = self.gameController.modifierModel

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

SelectController.switchCollectionController = function(self)
	local CollectionController = require("sphere.controllers.CollectionController")
	local collectionController = CollectionController:new()
	collectionController.selectController = self
	collectionController.gameController = self.gameController
	return self.gameController.screenManager:set(collectionController)
end

SelectController.switchResultController = function(self)
	local ResultController = require("sphere.controllers.ResultController")
	local resultController = ResultController:new()
	resultController.selectController = self
	resultController.gameController = self.gameController

	local selectModel = self.gameController.selectModel
	local scoreItemIndex = selectModel.scoreItemIndex
	local scoreItem = selectModel.scoreItem
	resultController:replayNoteChart("result", scoreItem.scoreEntry, scoreItemIndex)

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
