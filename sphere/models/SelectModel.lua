local Class = require("aqua.util.Class")

local SelectModel = Class:new()

SelectModel.load = function(self)
	local config = self.configModel:getConfig("select")
	self.config = config

	self.searchLineModel:setSearchString(config.searchString)

	self.noteChartSetItemIndex = self.noteChartSetLibraryModel:getItemIndex(config.noteChartSetEntryId)
	self.noteChartItemIndex = self.noteChartLibraryModel:getItemIndex(config.noteChartEntryId, config.noteChartDataEntryId)
	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(config.scoreEntryId)

	self:pullNoteChartSet()
end

SelectModel.update = function(self)
	self:updateSearch()
end

SelectModel.updateSearch = function(self)
	local newSearchString = self.searchLineModel.searchString
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
	self.noteChartItemIndex = 1
	self.scoreItemIndex = 1

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.config.noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id

	self:pullNoteChart()
end

SelectModel.scrollNoteChart = function(self, direction, destination)
	local noteChartItems = self.noteChartLibraryModel.items

	direction = direction or destination - self.noteChartItemIndex

	if not noteChartItems[self.noteChartItemIndex + direction] then
		return
	end

	self.noteChartItemIndex = self.noteChartItemIndex + direction
	self.scoreItemIndex = 1

	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id

	self:pullScore()
end

SelectModel.scrollScore = function(self, direction)
	local scoreItems = self.scoreLibraryModel.items

	if not scoreItems[self.scoreItemIndex + direction] then
		return
	end

	self.scoreItemIndex = self.scoreItemIndex + direction

	local scoreItem = scoreItems[self.scoreItemIndex]

	self.config.scoreEntryId = scoreItem.scoreEntry.id
end

SelectModel.pullNoteChartSet = function(self)
	self.noteChartLibraryModel:setSearchString(self.config.searchString)
	self.noteChartSetLibraryModel:setSearchString(self.config.searchString)
	self.noteChartSetLibraryModel:setCollection(self.config.collection)
	self.noteChartLibraryModel:updateItems()
	self.noteChartSetLibraryModel:updateItems()

	local noteChartSetItems = self.noteChartSetLibraryModel.items
	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]

	self.noteChartSetItemIndex = self.noteChartSetLibraryModel:getItemIndex(self.config.noteChartSetEntryId)

	noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	if noteChartSetItem then
		self.config.noteChartSetEntryId = noteChartSetItem.noteChartSetEntry.id
		self:pullNoteChart()
	end
end

SelectModel.pullNoteChart = function(self)
	self.noteChartLibraryModel:setNoteChartSetId(self.config.noteChartSetEntryId)
	self.noteChartLibraryModel:updateItems()

	local noteChartItems = self.noteChartLibraryModel.items
	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	self.noteChartItemIndex = self.noteChartLibraryModel:getItemIndex(self.config.noteChartEntryId, self.config.noteChartDataEntryId)

	noteChartItem = noteChartItems[self.noteChartItemIndex]
	if not noteChartItem then
		return
	end

	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id
	self:pullScore()
end

SelectModel.pullScore = function(self)
	local noteChartItems = self.noteChartLibraryModel.items
	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	self.scoreLibraryModel:setHash(noteChartItem.noteChartDataEntry.hash)
	self.scoreLibraryModel:setIndex(noteChartItem.noteChartDataEntry.index)
	self.scoreLibraryModel:updateItems()

	local scoreItems = self.scoreLibraryModel.items
	local scoreItem = scoreItems[self.scoreItemIndex]

	self.config.noteChartEntryId = noteChartItem.noteChartEntry.id
	self.config.noteChartDataEntryId = noteChartItem.noteChartDataEntry.id

	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(self.config.scoreEntryId)

	scoreItem = scoreItems[self.scoreItemIndex]
	if scoreItem then
		self.config.scoreEntryId = scoreItem.scoreEntry.id
	end
end

return SelectModel
