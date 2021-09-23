local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local InputViewConfig = require(viewspackage .. "InputView.InputViewConfig")
local InputNavigator = require(viewspackage .. "InputView.InputNavigator")
local InputListView = require(viewspackage .. "InputView.InputListView")

local InputView = ScreenView:new({construct = false})

InputView.views = {
	{"inputListView", InputListView, "InputListView"},
}

InputView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = InputViewConfig
	self.navigator = InputNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

InputView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return InputView
