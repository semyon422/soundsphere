local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local NoteChartSetListItemView = require(viewspackage .. "select.NoteChartSetListItemView")

local NoteChartSetListView = ListView:new()

NoteChartSetListView.init = function(self)
	self.ListItemView = NoteChartSetListItemView
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 16 / 9 * 0.61803 - 16 / 9 / 2
	self.y = 1 / 15
	self.w = 16 / 9 * (1 - 0.61803)
	self.h = 13 / 15
	self.itemCount = 13
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.noteChartSetList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("noteChartSetList")
	end)
	self:on("draw", self.drawFrame)

	ListView.init(self)
end

NoteChartSetListView.reloadItems = function(self)
	self.items = self.view.noteChartSetLibraryModel:getItems()
end

NoteChartSetListView.drawFrame = function(self)
	if self.navigator:checkNode("noteChartSetList") then
		self.isSelected = true
	else
		self.isSelected = false
	end
end

return NoteChartSetListView
