local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local NoteSkinViewConfig = require(viewspackage .. "NoteSkinView.NoteSkinViewConfig")
local NoteSkinNavigator = require(viewspackage .. "NoteSkinView.NoteSkinNavigator")
local NoteSkinListView = require(viewspackage .. "NoteSkinView.NoteSkinListView")

local NoteSkinView = ScreenView:new({construct = false})

NoteSkinView.views = {
	{"noteSkinListView", NoteSkinListView, "NoteSkinListView"},
}

NoteSkinView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = NoteSkinViewConfig
	self.navigator = NoteSkinNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

NoteSkinView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return NoteSkinView
