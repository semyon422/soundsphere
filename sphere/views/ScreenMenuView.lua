local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ScreenMenuItemView = require(viewspackage .. "ScreenMenuItemView")

local ScreenMenuView = Class:new()

ScreenMenuView.construct = function(self)
	self.itemView = ScreenMenuItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ScreenMenuView.load = function(self)
	self.state.selectedItem = 1
end

ScreenMenuView.draw = function(self)
	local items = self.config.screens
	for i = 1, self.config.rows do
		for j = 1, self.config.columns do
			local item = items[i] and items[i][j]
			if item then
				local itemView = self.itemView
				itemView.row = i
				itemView.column = j
				itemView.item = item
				itemView:draw()
			end
		end
	end
end

ScreenMenuView.receive = function(self, event)
	local items = self.config.screens
	for i = 1, self.config.rows do
		for j = 1, self.config.columns do
			local item = items[i] and items[i][j]
			if item then
				local itemView = self.itemView
				itemView.row = i
				itemView.column = j
				itemView.item = item
				itemView:receive(event)
			end
		end
	end
end

return ScreenMenuView
