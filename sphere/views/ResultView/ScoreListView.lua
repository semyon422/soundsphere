local viewspackage = (...):match("^(.-%.views%.)")

local ListView = require(viewspackage .. "ListView")
local ScoreListItemView = require(viewspackage .. "ResultView.ScoreListItemView")

local ScoreListView = ListView:new()

ScoreListView.construct = function(self)
	ListView.construct(self)
	self.itemView = ScoreListItemView:new()
	self.itemView.listView = self
end

ScoreListView.reloadItems = function(self)
	self.state.items = self.scoreLibraryModel.items
end

ScoreListView.getItemIndex = function(self)
	return self.selectModel.scoreItemIndex
end

ScoreListView.scrollUp = function(self)
	self.navigator:scrollScore("up")
end

ScoreListView.scrollDown = function(self)
	self.navigator:scrollScore("down")
end

return ScoreListView
