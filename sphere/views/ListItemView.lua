
local Node = require("aqua.util.Node")

local ListItemView = Node:new()

ListItemView.init = function(self)
	self:on("draw", self.draw)
end

ListItemView.draw = function(self)
	local item = self.item

	local x, y, w, h = self:getPosition()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(
		item.name,
		x,
		y,
		w
	)
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle(
		"fill",
		x,
		y,
		w,
		h
	)
end

ListItemView.getPosition = function(self)
	local listView = self.listView

	local cs = listView.cs

	local x = cs:X(listView.x, true)
	local y = cs:Y(listView.y, true)
	local w = cs:X(listView.w)
	local h = cs:Y(listView.h)

	return x, y + (self.index - 1) * h / listView.itemCount, w, h / listView.itemCount
end

return ListItemView
