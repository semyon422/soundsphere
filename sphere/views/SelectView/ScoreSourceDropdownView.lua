local DropdownView = require("sphere.views.DropdownView")

local ScoreSourceDropdownView = DropdownView:new()

ScoreSourceDropdownView.getCount = function(self)
	return #self.game.scoreLibraryModel.scoreSources
end

ScoreSourceDropdownView.getPreview = function(self)
	return self.game.configModel.configs.select.scoreSourceName
end

ScoreSourceDropdownView.select = function(self, i)
	local scoreSources = self.game.scoreLibraryModel.scoreSources
	local select = self.game.configModel.configs.select
	select.scoreSourceName = scoreSources[i]
	self.game.scoreLibraryModel:updateItems()
end

ScoreSourceDropdownView.getItemText = function(self, i)
	return self.game.scoreLibraryModel.scoreSources[i]
end

return ScoreSourceDropdownView
