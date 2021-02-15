local viewspackage = (...):match("^(.-%.views%.)")

local Node = require("aqua.util.Node")
local ListItemView = require(viewspackage .. "ListItemView")

local ListView = Node:new()

ListView.init = function(self)
	self:createListItemViews()

	self:on("draw", function() return self:draw() end)

	local cs = self.cs
	self:on("mousemoved", function(self, event)
		local x = cs:X(self.x, true)
		local y = cs:Y(self.y, true)
		local w = cs:X(self.w)
		local h = cs:Y(self.h)
		if event.args[1] >= x and event.args[1] < x + w and event.args[2] >= y and event.args[2] < y + h then
			self:call("select")
		end
	end)
end

ListView.createListItemViews = function(self)
	local ListItemView = self.ListItemView or ListItemView
	local listItemView = ListItemView:new()
	listItemView.listView = self
	listItemView:init()
	self.listItemView = listItemView
end

ListView.getListItemView = function(self, item)
	return self.listItemView
end

ListView.draw = function(self)
	for i = 1, self.itemCount do
		local itemIndex = i + self.selectedItem - math.ceil(self.itemCount / 2)
		local item = self.items[itemIndex]
		if item then
			local listItemView = self:getListItemView(item)
			listItemView.index = i
			listItemView.itemIndex = itemIndex
			listItemView.item = item
			listItemView:draw()
		end
	end
end

ListView.receive = function(self, event)
	for i = 1, self.itemCount do
		local itemIndex = i + self.selectedItem - math.ceil(self.itemCount / 2)
		local item = self.items[itemIndex]
		if item then
			local listItemView = self:getListItemView(item)
			listItemView.index = i
			listItemView.itemIndex = itemIndex
			listItemView.item = item
			listItemView:receive(event)
		end
	end
end

return ListView
