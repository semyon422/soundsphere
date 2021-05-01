local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ScreenMenuItemView = require(viewspackage .. "SelectView.ScreenMenuItemView")

local ScreenMenuView = Class:new()

ScreenMenuView.construct = function(self)
	self.itemView = ScreenMenuItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ScreenMenuView.load = function(self)
	self.state.selectedItem = 1
	self.items = self.config.screens
end

ScreenMenuView.draw = function(self)
	for i = 1, self.config.columns do
		local item = self.items[i]
		if item then
			local itemView = self.itemView
			itemView.index = i
			itemView.item = item
			itemView:draw()
		end
	end
end

ScreenMenuView.receive = function(self, event)
	for i = 1, self.config.columns do
		local item = self.items[i]
		if item then
			local itemView = self.itemView
			itemView.index = i
			itemView.item = item
			itemView:receive(event)
		end
	end
end

return ScreenMenuView
