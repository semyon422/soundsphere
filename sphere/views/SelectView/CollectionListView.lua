local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")

local CollectionListView = ListView()

CollectionListView.rows = 11

function CollectionListView:reloadItems()
	self.items = self.game.selectModel.collectionLibrary.items
    self.selectedCollection = self.game.selectModel.collectionItem
end

---@return number
function CollectionListView:getItemIndex()
	local collectionLibrary = self.game.selectModel.collectionLibrary
	return collectionLibrary.tree.selected
end

---@param count number
function CollectionListView:scroll(count)
	self.game.selectModel:scrollCollection(count)
end

---@param ... any?
function CollectionListView:draw(...)
	ListView.draw(self, ...)

	local collectionLibrary = self.game.selectModel.collectionLibrary

	local kp = just.keypressed
	if kp("up") or kp("left") then self:scroll(-1)
	elseif kp("down") or kp("right") then self:scroll(1)
	elseif kp("pageup") then self:scroll(-10)
	elseif kp("pagedown") then self:scroll(10)
	elseif kp("home") then self:scroll(-math.huge)
	elseif kp("end") then self:scroll(math.huge)
	elseif kp("return") then
		collectionLibrary:enter(self.game.selectModel.collectionItem)
		self.game.selectModel:scrollCollection(0, nil, true)
	end
end

---@param i number
---@param w number
---@param h number
function CollectionListView:drawItem(i, w, h)
	local tree = self.game.selectModel.collectionLibrary.tree
	local item = self.items[i]

	local name = item.name
	if item.depth == tree.depth and item.depth ~= 0 then
		name = "."
	elseif item.depth == tree.depth - 1 then
		name = ".."
	end

	TextCellImView(72, h, "right", "", item.count ~= 0 and item.count or "", true)
	just.sameline()
	just.indent(44)
	TextCellImView(math.huge, h, "left", item.path, name)
end

return CollectionListView
