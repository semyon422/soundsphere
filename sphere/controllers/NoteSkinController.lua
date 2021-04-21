local Class = require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")

local NoteSkinController = Class:new()


NoteSkinController.construct = function(self)
end

NoteSkinController.load = function(self)
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

	local view = theme:newView("NoteSkinView")
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

	-- modifierModel:load()
	noteChartModel:select()

	view:load()
end

NoteSkinController.unload = function(self)
	-- self.modifierModel:unload()
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
		return ScreenManager:set(self.selectController)
	end
end

return NoteSkinController
