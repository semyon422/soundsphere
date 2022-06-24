local Class = require("aqua.util.Class")
local ScreenMenuItemView = require("sphere.views.ScreenMenuItemView")

local ScreenMenuView = Class:new()

ScreenMenuView.construct = function(self)
	self.itemView = ScreenMenuItemView:new()
	self.itemView.listView = self
end

ScreenMenuView.load = function(self)
	self.selectedItem = 1
end

ScreenMenuView.draw = function(self)
	local items = self.items
	for i = 1, self.rows do
		for j = 1, self.columns do
			local item = items[i] and items[i][j]
			if item and item.displayName then
				local itemView = self.itemView
				itemView.row = i
				itemView.column = j
				itemView.item = item
				itemView:draw()
			end
		end
	end
end

return ScreenMenuView
