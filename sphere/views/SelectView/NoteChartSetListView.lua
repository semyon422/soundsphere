local ListView = require("sphere.views.ListView")

local NoteChartSetListView = ListView:new({construct = false})

NoteChartSetListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.noteChartSetLibraryModel.items
end

NoteChartSetListView.getItemIndex = function(self)
	return self.game.selectModel.noteChartSetItemIndex
end

NoteChartSetListView.scroll = function(self, count)
	self.game.selectModel:scrollNoteChartSet(count)
end

return NoteChartSetListView
