local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local NoteChartSetListItemView = require(viewspackage .. "select.NoteChartSetListItemView")

local NoteChartSetListView = ListView:new()

NoteChartSetListView.init = function(self)
	self.ListItemView = NoteChartSetListItemView
	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 16 / 9 / 3 / 2
	self.y = 0
	self.w = 16 / 9 / 3
	self.h = 1
	self.itemCount = 15
	self.selectedItem = 1

	self:reloadItems()

	self:on("update", function()
		self.selectedItem = self.navigator.noteChartSetList.selected
		self:reloadItems()
	end)
	self:on("select", function()
		self.navigator:setNode("noteChartSetList")
		self.view.selectedNode = self
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
