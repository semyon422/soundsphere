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

return ResultView
