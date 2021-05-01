local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local NoteChartListItemView = require(viewspackage .. "SelectView.NoteChartListItemView")

local NoteChartListView = Class:new()

NoteChartListView.construct = function(self)
	self.itemView = NoteChartListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

NoteChartListView.load = function(self)
	self.state.selectedItem = 1
	self:reloadItems()
end

NoteChartListView.reloadItems = function(self)
	self.state.items = self.noteChartLibraryModel.items
end

NoteChartListView.receive = function(self, event)
	local config = self.config
	if event.name == "wheelmoved" then
		local mx, my = love.mouse.getPosition()
		local cs = self.cs
		local x = cs:X(config.x / config.screen.h, true)
		local y = cs:Y(config.y / config.screen.h, true)
		local w = cs:X(config.w / config.screen.h)
		local h = cs:Y(config.h / config.screen.h)
		if mx >= x and mx < x + w and my >= y and my < y + h then
			local wy = event.args[2]
			if wy == 1 then
				self.navigator:scrollNoteChartUp()
			elseif wy == -1 then
				self.navigator:scrollNoteChartDown()
			end
		end
	end
end

NoteChartListView.update = function(self, dt)
	self.state.selectedItem = self.selectModel.noteChartItemIndex
	self:reloadItems()
end

NoteChartListView.draw = function(self)
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

return NoteChartListView
