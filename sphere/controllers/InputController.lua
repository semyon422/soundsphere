local Class = require("aqua.util.Class")

local InputController = Class:new()


InputController.construct = function(self)
end

InputController.load = function(self)
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local cacheModel = self.cacheModel
	local themeModel = self.themeModel
	local configModel = self.configModel
	local mountModel = self.mountModel
	local scoreModel = self.scoreModel
	local onlineModel = self.onlineModel
	local difficultyModel = self.difficultyModel
	local noteChartSetLibraryModel = self.noteChartSetLibraryModel
	local noteChartLibraryModel = self.noteChartLibraryModel
	local scoreLibraryModel = self.scoreLibraryModel
	local searchLineModel = self.searchLineModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("InputView")
	self.view = view

	view.controller = self
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
	view.noteChartSetLibraryModel = noteChartSetLibraryModel
	view.noteChartLibraryModel = noteChartLibraryModel
	view.scoreLibraryModel = scoreLibraryModel
	view.searchLineModel = searchLineModel
	view.backgroundModel = self.backgroundModel

	noteChartModel:select()

	view:load()
end

InputController.unload = function(self)
	self.view:unload()
end

InputController.update = function(self, dt)
	self.view:update(dt)
end

InputController.draw = function(self)
	self.view:draw()
end

InputController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setInputBinding" then
		self.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "goSelectScreen" then
		return self.gameController.screenManager:set(self.selectController)
	end
end

return InputController
