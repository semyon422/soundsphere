local Class = require("aqua.util.Class")

local NoteSkinController = Class:new()

NoteSkinController.construct = function(self) end

NoteSkinController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("NoteSkinView")
	self.view = view

	view.controller = self
	view.themeModel = themeModel
	view.noteChartModel = self.gameController.noteChartModel
	view.modifierModel = self.gameController.modifierModel
	view.noteSkinModel = self.gameController.noteSkinModel
	view.inputModel = self.gameController.inputModel
	view.cacheModel = self.gameController.cacheModel
	view.configModel = self.gameController.configModel
	view.mountModel = self.gameController.mountModel
	view.scoreModel = self.gameController.scoreModel
	view.onlineModel = self.gameController.onlineModel
	view.noteChartSetLibraryModel = self.gameController.noteChartSetLibraryModel
	view.noteChartLibraryModel = self.gameController.noteChartLibraryModel
	view.scoreLibraryModel = self.gameController.scoreLibraryModel
	view.searchLineModel = self.gameController.searchLineModel
	view.backgroundModel = self.gameController.backgroundModel

	noteChartModel:load()

	view:load()
end

NoteSkinController.unload = function(self)
	self.view:unload()
end

NoteSkinController.update = function(self, dt)
	self.view:update(dt)
end

NoteSkinController.draw = function(self)
	self.view:draw()
end

NoteSkinController.receive = function(self, event)
	self.view:receive(event)

    if event.name == "setNoteSkin" then
		self.noteSkinModel:setDefaultNoteSkin(event.noteSkin)
	elseif event.name == "goSelectScreen" then
		return self.gameController.screenManager:set(self.selectController)
	end
end

return NoteSkinController
