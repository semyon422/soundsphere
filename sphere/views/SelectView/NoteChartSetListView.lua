local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local NoteChartSetListItemView = require(viewspackage .. "SelectView.NoteChartSetListItemView")

local NoteChartSetListView = Class:new()

NoteChartSetListView.construct = function(self)
	self.itemView = NoteChartSetListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

NoteChartSetListView.load = function(self)
	self.state.selectedItem = 1
	self:reloadItems()
end

NoteChartSetListView.reloadItems = function(self)
	self.state.items = self.noteChartSetLibraryModel.items
end

NoteChartSetListView.receive = function(self, event)
	local config = self.config
	if event.name == "mousemoved" then
		local cs = self.cs
		local x = cs:X(config.x, true)
		local y = cs:Y(config.y, true)
		local w = cs:X(config.w)
		local h = cs:Y(config.h)
		if event.args[1] >= x and event.args[1] < x + w and event.args[2] >= y and event.args[2] < y + h then
			-- self:call("select")
		end
	end
end

NoteChartSetListView.update = function(self, dt)
	self.state.selectedItem = self.selectModel.noteChartSetItemIndex
	self:reloadItems()
end

NoteChartSetListView.draw = function(self)
	local state = self.state
	local config = self.config

	for i = 1, config.rows do
		local itemIndex = i + state.selectedItem - math.ceil(config.rows / 2)
		local item = state.items[itemIndex]
		if item then
			local itemView = self.itemView
			itemView.index = i
			itemView.itemIndex = itemIndex
			itemView.item = item
			itemView.listView = self
			itemView.prevItem = state.items[itemIndex - 1]
			itemView.nextItem = state.items[itemIndex + 1]
			itemView:draw()
		end
	end
end

return NoteChartSetListView
