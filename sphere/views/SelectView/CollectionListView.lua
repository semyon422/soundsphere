local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CollectionListItemView = require(viewspackage .. "SelectView.CollectionListItemView")

local CollectionListView = ListView:new({construct = false})

CollectionListView.construct = function(self)
	ListView.construct(self)
	self.itemView = CollectionListItemView:new()
	self.itemView.listView = self
end

CollectionListView.reloadItems = function(self)
	self.state.items = self.gameController.collectionModel.items
    self.state.selectedCollection = self.gameController.selectModel.collectionItem
end

CollectionListView.getItemIndex = function(self)
	return self.gameController.selectModel.collectionItemIndex
end

CollectionListView.scrollUp = function(self)
	self.navigator:scrollCollection("up")
end

CollectionListView.scrollDown = function(self)
	self.navigator:scrollCollection("down")
end

return CollectionListView
