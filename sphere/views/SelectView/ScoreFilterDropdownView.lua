local DropdownView = require("sphere.views.DropdownView")

local ScoreFilterDropdownView = DropdownView:new()

ScoreFilterDropdownView.getCount = function(self)
	return #self.game.configModel.configs.filters.score
end

ScoreFilterDropdownView.scroll = function(self, delta)
	local filters = self.game.configModel.configs.filters.score
	local select = self.game.configModel.configs.select
	local index
	for i, filter in ipairs(filters) do
		if filter.name == select.scoreFilterName then
			index = i
			break
		end
	end
	if not index then
		index = 0
	end
	index = index + delta
	if index < 1 then
		index = #filters
	elseif index > #filters then
		index = 1
	end
	select.scoreFilterName = filters[index].name
	self.game.selectModel:pullScore()
end

ScoreFilterDropdownView.getPreview = function(self)
	return self.game.configModel.configs.select.scoreFilterName
end

ScoreFilterDropdownView.select = function(self, i)
	local filters = self.game.configModel.configs.filters.score
	local select = self.game.configModel.configs.select
	select.scoreFilterName = filters[i].name
	self.game.selectModel:pullScore()
end

ScoreFilterDropdownView.getItemText = function(self, i)
	return self.game.configModel.configs.filters.score[i].name
end

return ScoreFilterDropdownView
