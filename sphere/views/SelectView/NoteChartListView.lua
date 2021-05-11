local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local NoteChartListItemView = require(viewspackage .. "SelectView.NoteChartListItemView")

local NoteChartListView = ListView:new()

NoteChartListView.construct = function(self)
	ListView.construct(self)
	self.itemView = NoteChartListItemView:new()
	self.itemView.listView = self
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

NoteChartListView.reloadItems = function(self)
	self.state.items = self.noteChartLibraryModel.items
end

NoteChartListView.getItemIndex = function(self)
	return self.selectModel.noteChartItemIndex
end

NoteChartListView.scrollUp = function(self)
	self.navigator:scrollNoteChart("up")
end

NoteChartListView.scrollDown = function(self)
	self.navigator:scrollNoteChart("down")
end

return NoteChartListView
