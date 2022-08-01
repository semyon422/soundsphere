local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.views.SelectView.TextCellImView")

local CollectionListView = ListView:new({construct = false})

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

CollectionListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	TextCellImView(72, h, "right", "", item.count ~= 0 and item.count or "", true)
	just.sameline()
	just.indent(44)
	TextCellImView(math.huge, h, "left", item.shortPath, item.name)
end

return CollectionListView
