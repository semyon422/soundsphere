local DropdownView = require("sphere.views.DropdownView")

local NotechartFilterDropdownView = DropdownView:new()

NotechartFilterDropdownView.getCount = function(self)
	return #self.game.configModel.configs.filters.notechart
end

NotechartFilterDropdownView.scroll = function(self, delta)
	local filters = self.game.configModel.configs.filters.notechart
	local select = self.game.configModel.configs.select
	local index
	for i, filter in ipairs(filters) do
		if filter.name == select.filterName then
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
	select.filterName = filters[index].name
	self.game.selectModel:debouncePullNoteChartSet()
end

NotechartFilterDropdownView.getPreview = function(self)
	return self.game.configModel.configs.select.filterName
end

NotechartFilterDropdownView.select = function(self, i)
	local filters = self.game.configModel.configs.filters.notechart
	local select = self.game.configModel.configs.select
	select.filterName = filters[i].name
	self.game.selectModel:debouncePullNoteChartSet()
end

NotechartFilterDropdownView.getItemText = function(self, i)
	return self.game.configModel.configs.filters.notechart[i].name
end

return NotechartFilterDropdownView
