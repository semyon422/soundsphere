local ListView = require("sphere.views.ListView")

local ScoreListView = ListView:new({construct = false})

ScoreListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.scoreStateCounter
	self.items = self.game.scoreLibraryModel.items
end

ScoreListView.getItemIndex = function(self)
	return self.game.selectModel.scoreItemIndex
end

ScoreListView.scroll = function(self, delta)
	self.game.selectModel:scrollScore(delta)
end

return ScoreListView
