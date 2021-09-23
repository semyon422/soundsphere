local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local NoteSkinListItemView = require(viewspackage .. "NoteSkinView.NoteSkinListItemView")

local NoteSkinListView = ListView:new({construct = false})

NoteSkinListView.construct = function(self)
	ListView.construct(self)
	self.itemView = NoteSkinListItemView:new()
	self.itemView.listView = self
end

NoteSkinListView.reloadItems = function(self)
    local noteChart = self.gameController.noteChartModel.noteChart
	self.state.items = self.gameController.noteSkinModel:getNoteSkins(noteChart.inputMode)
    self.state.selectedNoteSkin = self.gameController.noteSkinModel:getNoteSkin(noteChart.inputMode)
end

NoteSkinListView.getItemIndex = function(self)
	return self.navigator.noteSkinItemIndex
end

NoteSkinListView.scrollUp = function(self)
	self.navigator:scrollNoteSkin("up")
end

NoteSkinListView.scrollDown = function(self)
	self.navigator:scrollNoteSkin("down")
end

NoteSkinListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" or event.name == "mousereleased" or event.name == "mousemoved" then
		self:receiveItems(event)
	end
end

return NoteSkinListView
