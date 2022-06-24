local ListView = require("sphere.views.ListView")
local CollectionListItemView = require("sphere.views.SelectView.CollectionListItemView")

local CollectionListView = ListView:new({construct = false})

CollectionListView.construct = function(self)
	ListView.construct(self)
	self.itemView = CollectionListItemView:new()
	self.itemView.listView = self
end

CollectionListView.reloadItems = function(self)
	self.items = self.game.collectionModel.items
    self.selectedCollection = self.game.selectModel.collectionItem
end

CollectionListView.getItemIndex = function(self)
	return self.game.selectModel.collectionItemIndex
end

CollectionListView.scrollUp = function(self)
	self.navigator:scrollCollection("up")
end

CollectionListView.scrollDown = function(self)
	self.navigator:scrollCollection("down")
end

return CollectionListView
