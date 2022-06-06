local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local ScoreListItemView = require(viewspackage .. "ResultView.ScoreListItemView")

local ScoreListView = ListView:new({construct = false})

ScoreListView.construct = function(self)
	ListView.construct(self)
	self.itemView = ScoreListItemView:new()
	self.itemView.listView = self
end

ScoreListView.reloadItems = function(self)
	self.state.items = self.game.scoreLibraryModel.items
end

ScoreListView.getItemIndex = function(self)
	return self.game.selectModel.scoreItemIndex
end

ScoreListView.scrollUp = function(self)
	self.navigator:scrollScore("up")
end

ScoreListView.scrollDown = function(self)
	self.navigator:scrollScore("down")
end

ScoreListView.receive = function(self, event)
	if event.name == "wheelmoved" then
		return self:wheelmoved(event)
	end
	if event.name == "mousepressed" then
		self:receiveItems(event)
	end
end

return ScoreListView
