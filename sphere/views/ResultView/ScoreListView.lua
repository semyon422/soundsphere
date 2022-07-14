local ListView = require("sphere.views.ListView")

local ScoreListView = ListView:new({construct = false})

ScoreListView.reloadItems = function(self)
	self.items = self.game.scoreLibraryModel.items
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

return ScoreListView
