local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local CollectionViewConfig = require(viewspackage .. "CollectionView.CollectionViewConfig")
local CollectionNavigator = require(viewspackage .. "CollectionView.CollectionNavigator")
local CollectionListView = require(viewspackage .. "CollectionView.CollectionListView")
local CacheView = require(viewspackage .. "CollectionView.CacheView")

local CollectionView = ScreenView:new({construct = false})

CollectionView.views = {
	{"collectionListView", CollectionListView, "CollectionListView"},
	{"cacheView", CacheView, "CacheView"},
}

CollectionView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = CollectionViewConfig
	self.navigator = CollectionNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

CollectionView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return CollectionView
