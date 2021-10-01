local Class = require("aqua.util.Class")

local SelectModel = Class:new()

SelectModel.load = function(self)
	local config = self.configModel.configs.select
	self.config = config

	self.searchModel:setSearchString(config.searchString)
	self:setSearchMode(config.searchMode)
	self.sortModel.name = config.sortFunction
	self.noteChartSetLibraryModel.sortFunction = self.sortModel:getSortFunction()
	self.noteChartSetLibraryModel.collapse = config.collapse

	self.noteChartSetItemIndex = self.noteChartSetLibraryModel:getItemIndex(config.noteChartSetEntryId)
	self.noteChartItemIndex = self.noteChartLibraryModel:getItemIndex(config.noteChartEntryId, config.noteChartDataEntryId)
	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(config.scoreEntryId)

	self.noteChartSetItem = self.noteChartSetLibraryModel.items[self.noteChartSetItemIndex]
	self.noteChartItem = self.noteChartLibraryModel.items[self.noteChartItemIndex]
	self.scoreItem = self.scoreLibraryModel.items[self.scoreItemIndex]

	self:pullNoteChartSet()
end

SelectModel.setSearchMode = function(self, searchMode)
	if searchMode ~= "show" and searchMode ~= "hide" then
		return
	end
	self.noteChartSetLibraryModel.searchMode = searchMode
	self.noteChartLibraryModel.searchMode = searchMode
	self.searchModel.searchMode = searchMode
end

SelectModel.setSortFunction = function(self, sortFunctionName)
	local config = self.config
	config.sortFunction = sortFunctionName
	self.sortModel.name = sortFunctionName
	self.noteChartSetLibraryModel.sortFunction = self.sortModel:getSortFunction()
	self:pullNoteChartSet()
end

SelectModel.scrollSortFunction = function(self, delta)
	self.sortModel:increase(delta)
	self:setSortFunction(self.sortModel.name)
end

SelectModel.changeSearchMode = function(self)
	local config = self.config
	if config.searchMode == "hide" then
		config.searchMode = "show"
	else
		config.searchMode = "hide"
	end
	self:setSearchMode(config.searchMode)
	self:pullNoteChartSet()
end

SelectModel.changeCollapse = function(self)
	local config = self.config
	config.collapse = not config.collapse
	self.noteChartSetLibraryModel.collapse = config.collapse
	self:pullNoteChartSet()
end

SelectModel.update = function(self)
	self:updateSearch()
end

SelectModel.updateSearch = function(self)
	local newSearchString = self.searchModel.searchString
	if self.config.searchString ~= newSearchString then
		self.config.searchString = newSearchString
		self:pullNoteChartSet()
	end
end

SelectModel.scrollNoteChartSet = function(self, direction, destination)
	local noteChartSetItems = self.noteChartSetLibraryModel.items

	direction = direction or destination - self.noteChartSetItemIndex
	if not noteChartSetItems[self.noteChartSetItemIndex + direction] then
		return
	end

	self.noteChartSetItemIndex = self.noteChartSetItemIndex + direction

	local oldNoteChartSetItem = self.noteChartSetItem

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.noteChartSetItem = noteChartSetItem
	self.config.noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id
	self.config.noteChartEntryId = noteChartSetItem.noteChartEntry and noteChartSetItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartSetItem.noteChartDataEntry and noteChartSetItem.noteChartDataEntry.id

	self:pullNoteChart(oldNoteChartSetItem.noteChartSetEntry.id == noteChartSetItem.noteChartSetEntry.id)
end

SelectModel.scrollNoteChart = function(self, direction, destination)
	local noteChartItems = self.noteChartLibraryModel.items

	direction = direction or destination - self.noteChartItemIndex

	if not noteChartItems[self.noteChartItemIndex + direction] then
		return
	end

	self.noteChartItemIndex = self.noteChartItemIndex + direction

	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem

	self.config.noteChartSetEntryId = noteChartItem.noteChartSetEntry.id
	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry and noteChartItem.noteChartDataEntry.id

	self:pullNoteChartSet(true)
	self:pullScore()
end

SelectModel.scrollScore = function(self, direction, destination)
	local scoreItems = self.scoreLibraryModel.items

	direction = direction or destination - self.scoreItemIndex

	if not scoreItems[self.scoreItemIndex + direction] then
		return
	end

	self.scoreItemIndex = self.scoreItemIndex + direction

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem

	self.config.scoreEntryId = scoreItem.scoreEntry.id
end

SelectModel.pullNoteChartSet = function(self, noUpdate)
	if not noUpdate then
		self.searchModel:setCollection(self.collectionModel.collection)
		self.noteChartLibraryModel:updateItems()
		self.noteChartSetLibraryModel:updateItems()
	end

	local noteChartSetItems = self.noteChartSetLibraryModel.items
	self.noteChartSetItemIndex = self.noteChartSetLibraryModel:getItemIndex(
		self.config.noteChartSetEntryId,
		self.config.noteChartEntryId,
		self.config.noteChartDataEntryId
	)

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.noteChartSetItem = noteChartSetItem
	if noteChartSetItem then
		self.config.noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id
		self:pullNoteChart(noUpdate)
	end
end

SelectModel.pullNoteChart = function(self, noUpdate)
	if not noUpdate then
		self.noteChartLibraryModel:setNoteChartSetId(self.config.noteChartSetEntryId)
		self.noteChartLibraryModel:updateItems()
	end

	local noteChartItems = self.noteChartLibraryModel.items
	self.noteChartItemIndex = self.noteChartLibraryModel:getItemIndex(
		self.config.noteChartEntryId,
		self.config.noteChartDataEntryId
	)

	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem
	if not noteChartItem then
		return
	end

	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id
	self:pullScore(noUpdate)
end

SelectModel.pullScore = function(self, noUpdate)
	local noteChartItems = self.noteChartLibraryModel.items
	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	if not noUpdate then
		self.scoreLibraryModel:setHash(noteChartItem.noteChartDataEntry.hash)
		self.scoreLibraryModel:setIndex(noteChartItem.noteChartDataEntry.index)
		self.scoreLibraryModel:updateItems()
	end

	local scoreItems = self.scoreLibraryModel.items

	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id

	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(self.config.scoreEntryId) or self.scoreItemIndex

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem
	if scoreItem then
		self.config.scoreEntryId = scoreItem.scoreEntry.id
	end
end

return SelectModel
