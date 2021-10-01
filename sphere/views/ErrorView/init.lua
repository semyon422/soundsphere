local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")
local ErrorViewConfig = require(viewspackage .. "ErrorView.ErrorViewConfig")
local ErrorNavigator = require(viewspackage .. "ErrorView.ErrorNavigator")

local ErrorView = ScreenView:new({construct = false})

ErrorView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ErrorViewConfig
	self.navigator = ErrorNavigator:new()
	self:createViews(ScreenView.views)
end

ErrorView.load = function(self)
	self:loadViews(ScreenView.views)
	ScreenView.load(self)
end

return ErrorView
