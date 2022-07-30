local ListView = require("sphere.views.ListView")

local NoteChartListView = ListView:new({construct = false})

NoteChartListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.noteChartStateCounter
	self.items = self.game.noteChartLibraryModel.items
end

NoteChartListView.getItemIndex = function(self)
	return self.game.selectModel.noteChartItemIndex
end

NoteChartListView.scroll = function(self, count)
	self.game.selectModel:scrollNoteChart(count)
end

return NoteChartListView
