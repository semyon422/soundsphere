local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CollectionListItemView = require(viewspackage .. "CollectionView.CollectionListItemView")

local CollectionListView = ListView:new()

CollectionListView.construct = function(self)
	ListView.construct(self)
	self.itemView = CollectionListItemView:new()
	self.itemView.listView = self
end

CollectionListView.reloadItems = function(self)
	self.state.items = self.collectionModel.items
    self.state.selectedCollection = self.collectionModel.collection
end

CollectionListView.getItemIndex = function(self)
	return self.navigator.collectionItemIndex
end

CollectionListView.scrollUp = function(self)
	self.navigator:scrollCollection("up")
end

CollectionListView.scrollDown = function(self)
	self.navigator:scrollCollection("down")
end

CollectionListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

return CollectionListView
