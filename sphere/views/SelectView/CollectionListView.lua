local ListView = require("sphere.views.ListView")
local ListItemView = require("sphere.views.ListItemView")

local CollectionListView = ListView:new({construct = false})

CollectionListView.construct = function(self)
	ListView.construct(self)
	self.itemView = ListItemView:new()
	self.itemView.listView = self
end

CollectionListView.reloadItems = function(self)
	self.items = self.game.collectionModel.items
    self.selectedCollection = self.game.selectModel.collectionItem
end

CollectionListView.getItemIndex = function(self)
	return self.game.selectModel.collectionItemIndex
end

CollectionListView.scroll = function(self, count)
	self.game.selectModel:scrollCollection(count)
end

return CollectionListView
