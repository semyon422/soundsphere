local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local NoteChartListItemView = require(viewspackage .. "SelectView.NoteChartListItemView")

local NoteChartListView = ListView:new()

NoteChartListView.init = function(self)
	self.ListItemView = NoteChartListItemView
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 16 / 9 / 2 - 16 / 9 * 0.61803
	self.y = 1 / 15
	self.w = 16 / 9 * 0.61803 * (1 - 0.61803)
	self.h = 13 / 15
	self.itemCount = 13
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.noteChartList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("noteChartList")
	end)
	self:on("draw", self.drawFrame)

	ListView.init(self)
end

NoteChartListView.reloadItems = function(self)
	self.items = self.view.noteChartLibraryModel:getItems()
end

NoteChartListView.drawFrame = function(self)
	if self.navigator:checkNode("noteChartList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return NoteChartListView
