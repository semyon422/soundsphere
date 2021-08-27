local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local CollectionViewConfig = require(viewspackage .. "CollectionView.CollectionViewConfig")
local CollectionNavigator = require(viewspackage .. "CollectionView.CollectionNavigator")
local CollectionListView = require(viewspackage .. "CollectionView.CollectionListView")

local CollectionView = ScreenView:new()

CollectionView.construct = function(self)
	self.viewConfig = CollectionViewConfig
	self.navigator = CollectionNavigator:new()
	self.collectionListView = CollectionListView:new()
end

CollectionView.load = function(self)
	local navigator = self.navigator
	local collectionListView = self.collectionListView

	navigator.collectionModel = self.collectionModel

	collectionListView.collectionModel = self.collectionModel
	collectionListView.navigator = navigator
	collectionListView.view = self

	local sequenceView = self.sequenceView
	sequenceView:setView("CollectionListView", collectionListView)

	ScreenView.load(self)
end

return CollectionView
