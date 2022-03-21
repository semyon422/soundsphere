local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local NoteChartSetListItemView = require(viewspackage .. "SelectView.NoteChartSetListItemView")

local NoteChartSetListView = ListView:new({construct = false})

NoteChartSetListView.construct = function(self)
	ListView.construct(self)
	self.itemView = NoteChartSetListItemView:new()
	self.itemView.listView = self
end

NoteChartSetListView.reloadItems = function(self)
	self.state.stateCounter = self.gameController.selectModel.noteChartSetStateCounter
	self.state.items = self.gameController.noteChartSetLibraryModel.items
end

NoteChartSetListView.getItemIndex = function(self)
	return self.gameController.selectModel.noteChartSetItemIndex
end

NoteChartSetListView.scrollUp = function(self)
	self.navigator:scrollNoteChartSet("up")
end

NoteChartSetListView.scrollDown = function(self)
	self.navigator:scrollNoteChartSet("down")
end

return NoteChartSetListView
