local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local ScreenMenuItemView = require(viewspackage .. "ScreenMenuItemView")

local ScreenMenuView = Class:new()

ScreenMenuView.construct = function(self)
	self.itemView = ScreenMenuItemView:new()
	self.itemView.listView = self
end

ScreenMenuView.load = function(self)
	self.state.selectedItem = 1
end

ScreenMenuView.draw = function(self)
	local config = self.config
	local items = config.items
	for i = 1, self.config.rows do
		for j = 1, self.config.columns do
			local item = items[i] and items[i][j]
			if item and item.displayName then
				local itemView = self.itemView
				itemView.row = i
				itemView.column = j
				itemView.item = item
				itemView:draw()
				if config ~= self.config then
					return
				end
			end
		end
	end
end

return ScreenMenuView
