
local Node = require("aqua.util.Node")

local ListItemView = Node:new()

ListItemView.init = function(self)
	self:on("draw", self.draw)
end

ListItemView.draw = function(self)
	local listView = self.listView

	local itemIndex = self.index + listView.selectedItem - math.ceil(listView.itemCount / 2)
	if not listView.items[itemIndex] then
		return
	end

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	local index = self.index

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(
		listView.items[itemIndex].name,
		x,
		y + (index - 1) * h / listView.itemCount,
		w
	)
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		x,
		y + (index - 1) * h / listView.itemCount,
		w,
		h / listView.itemCount
	)
end

return ListItemView
