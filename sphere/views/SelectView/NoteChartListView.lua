local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local NoteChartListItemView = require(viewspackage .. "SelectView.NoteChartListItemView")

local NoteChartListView = ListView:new({construct = false})

NoteChartListView.construct = function(self)
	ListView.construct(self)
	self.itemView = NoteChartListItemView:new()
	self.itemView.listView = self
end

NoteChartListView.reloadItems = function(self)
	self.state.stateCounter = self.gameController.selectModel.noteChartStateCounter
	self.state.items = self.gameController.noteChartLibraryModel.items
end

NoteChartListView.getItemIndex = function(self)
	return self.gameController.selectModel.noteChartItemIndex
end

NoteChartListView.scrollUp = function(self)
	self.navigator:scrollNoteChart("up")
end

NoteChartListView.scrollDown = function(self)
	self.navigator:scrollNoteChart("down")
end

NoteChartListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

return NoteChartListView
