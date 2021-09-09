local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local CollectionViewConfig = require(viewspackage .. "CollectionView.CollectionViewConfig")
local CollectionNavigator = require(viewspackage .. "CollectionView.CollectionNavigator")
local CollectionListView = require(viewspackage .. "CollectionView.CollectionListView")
local CacheView = require(viewspackage .. "CollectionView.CacheView")

local CollectionView = ScreenView:new({construct = false})

CollectionView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = CollectionViewConfig
	self.navigator = CollectionNavigator:new()
	self.collectionListView = CollectionListView:new()
	self.cacheView = CacheView:new()
end

CollectionView.load = function(self)
	local navigator = self.navigator
	local collectionListView = self.collectionListView
	local cacheView = self.cacheView

	navigator.collectionModel = self.collectionModel

	cacheView.navigator = navigator
	cacheView.cacheModel = self.cacheModel

	collectionListView.collectionModel = self.collectionModel
	collectionListView.navigator = navigator
	collectionListView.view = self

	local sequenceView = self.sequenceView
	sequenceView:setView("CollectionListView", collectionListView)
	sequenceView:setView("CacheView", cacheView)

	ScreenView.load(self)
end

return CollectionView
