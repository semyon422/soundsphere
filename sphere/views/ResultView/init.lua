local ScreenView = require("sphere.views.ScreenView")

local ResultNavigator = require("sphere.views.ResultView.ResultNavigator")
local ResultViewConfig = require("sphere.views.ResultView.ResultViewConfig")

local ResultView = ScreenView:new({construct = false})

ResultView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
end

ResultView.load = function(self)
	if self.prevView == self.game.selectView then
		self.game.resultController:load()
	end
	self.subscreen = ""
	ScreenView.load(self)
end

ResultView.unload = function(self)
	ScreenView.unload(self)
end

ResultView.reload = function(self)
	ScreenView.unload(self)
	ScreenView.load(self)
	self.sequenceView.abortIterating = false
end

ResultView.loadScore = function(self, itemIndex)
	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.scoreLibraryModel.items[itemIndex]
	end
	self.game.resultController:replayNoteChart("result", scoreEntry)
	self:reload()
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
	end
end

ResultView.play = function(self, mode)
	local scoreEntry = self.game.selectModel.scoreItem
	local isResult = self.game.resultController:replayNoteChart(mode, scoreEntry)
	if isResult then
		return self.view:reload()
	end
	self:changeScreen("gameplayView")
end

ResultView.quit = function(self)
	if self.game.multiplayerModel.room then
		return self:changeScreen("multiplayerView")
	end
	self:changeScreen("selectView")
end

return ResultView
