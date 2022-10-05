local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")

local CollectionListView = ListView:new()

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

CollectionListView.draw = function(self)
	ListView.draw(self)

	local kp = just.keypressed
	if kp("up") or kp("left") then self:scroll(-1)
	elseif kp("down") or kp("right") then self:scroll(1)
	elseif kp("pageup") then self:scroll(-10)
	elseif kp("pagedown") then self:scroll(10)
	elseif kp("home") then self:scroll(-math.huge)
	elseif kp("end") then self:scroll(math.huge)
	end
end

CollectionListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	TextCellImView(72, h, "right", "", item.count ~= 0 and item.count or "", true)
	just.sameline()
	just.indent(44)
	TextCellImView(math.huge, h, "left", item.shortPath, item.name)
end

return CollectionListView
