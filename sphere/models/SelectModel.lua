local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local aquathread = require("aqua.thread")

local SelectModel = Class:new()

SelectModel.construct = function(self)
	self.noteChartSetItemIndex = 1
	self.noteChartItemIndex = 1
	self.scoreItemIndex = 1
	self.pullingNoteChartSet = false
end

SelectModel.debounceTime = 0.5

SelectModel.load = function(self)
	local config = self.game.configModel.configs.select
	self.config = config

	self.game.searchModel:setSearchFilter(config.searchFilter)
	self.game.searchModel:setSearchLamp(config.searchLamp)
	self.game.searchModel:setSearchMode(config.searchMode)
	self.game.sortModel.name = config.sortFunction
	self.game.noteChartSetLibraryModel.collapse = config.collapse

	self.noteChartSetStateCounter = 1
	self.noteChartStateCounter = 1
	self.searchStateCounter = self.game.searchModel.stateCounter

	self.collectionItemIndex = self.game.collectionModel:getItemIndex(config.collection)
	self.collectionItem = self.game.collectionModel.items[self.collectionItemIndex]

	self:coroPullNoteChartSet()
end

SelectModel.debouncePullNoteChartSet = function(self, ...)
	aquatimer.debounce(self, "pullNoteChartSetDebounce", self.debounceTime, self.pullNoteChartSet, self, ...)
end

SelectModel.coroPullNoteChartSet = aquathread.coro(function(self, ...)
	return self:pullNoteChartSet(...)
end)

SelectModel.setSortFunction = function(self, sortFunctionName)
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.sortFunction = sortFunctionName
	self.sortModel.name = sortFunctionName
	self:debouncePullNoteChartSet()
end

SelectModel.scrollSortFunction = function(self, delta)
	self.game.sortModel:increase(delta)
	self:setSortFunction(self.game.sortModel.name)
end

SelectModel.changeSearchMode = function(self)
	self.game.searchModel:switchSearchMode()
	self.config.searchMode = self.game.searchModel.searchMode
end

SelectModel.changeCollapse = function(self)
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.collapse = not config.collapse
	self.game.noteChartSetLibraryModel.collapse = config.collapse
	self:debouncePullNoteChartSet()
end

SelectModel.update = function(self)
	local stateCounter = self.game.searchModel.stateCounter
	if self.searchStateCounter == stateCounter or self.pullingNoteChartSet then
		return
	end
	self.config.searchFilter = self.game.searchModel.searchFilter
	self.config.searchLamp = self.game.searchModel.searchLamp
	self.searchStateCounter = stateCounter
	self:debouncePullNoteChartSet()
end

SelectModel.scrollCollection = function(self, direction, destination)
	if self.pullingNoteChartSet then
		return
	end

	local collectionItems = self.game.collectionModel.items

	destination = math.min(math.max(destination or self.collectionItemIndex + direction, 1), #collectionItems)
	if not collectionItems[destination] or self.collectionItemIndex == destination then
		return
	end
	self.collectionItemIndex = destination

	local oldCollectionItem = self.collectionItem

	local collectionItem = collectionItems[self.collectionItemIndex]
	self.collectionItem = collectionItem
	self.config.collection = collectionItem.path

	self:debouncePullNoteChartSet(oldCollectionItem and oldCollectionItem.path == collectionItem.path)
end

SelectModel.scrollRandom = function(self)
	local noteChartSetItems = self.game.noteChartSetLibraryModel.items

	local destination = math.random(1, #noteChartSetItems)

	self:scrollNoteChartSet(nil, destination)
end

SelectModel.setConfig = function(self, item)
	self.config.noteChartSetEntryId = item.setId
	self.config.noteChartEntryId = item.noteChartId
	self.config.noteChartDataEntryId = item.noteChartDataId
end

SelectModel.scrollNoteChartSet = function(self, direction, destination)
	local noteChartSetItems = self.game.noteChartSetLibraryModel.items

	destination = math.min(math.max(destination or self.noteChartSetItemIndex + direction, 1), #noteChartSetItems)
	if not noteChartSetItems[destination] or self.noteChartSetItemIndex == destination then
		return
	end
	self.noteChartSetItemIndex = destination

	local oldNoteChartSetItem = self.noteChartSetItem

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.noteChartSetItem = noteChartSetItem
	self:setConfig(noteChartSetItem)

	self:pullNoteChart(oldNoteChartSetItem and oldNoteChartSetItem.setId == noteChartSetItem.setId)
end

SelectModel.scrollNoteChart = function(self, direction, destination)
	local noteChartItems = self.game.noteChartLibraryModel.items

	direction = direction or destination - self.noteChartItemIndex

	destination = math.min(math.max(destination or self.noteChartItemIndex + direction, 1), #noteChartItems)
	if not noteChartItems[destination] or self.noteChartItemIndex == destination then
		return
	end
	self.noteChartItemIndex = destination

	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem

	self:setConfig(noteChartItem)

	self:pullNoteChartSet(true)
	self:pullScore()
end

SelectModel.scrollScore = function(self, direction, destination)
	local scoreItems = self.game.scoreLibraryModel.items

	destination = math.min(math.max(destination or self.scoreItemIndex + direction, 1), #scoreItems)
	if not scoreItems[destination] or self.scoreItemIndex == destination then
		return
	end
	self.scoreItemIndex = destination

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem

	self.config.scoreEntryId = scoreItem.id
end

SelectModel.pullNoteChartSet = function(self, noUpdate)
	self.pullingNoteChartSet = true

	if not noUpdate then
		self.game.searchModel:setCollection(self.collectionItem)
		self.game.noteChartSetLibraryModel:updateItems()
	end

	local noteChartSetItems = self.game.noteChartSetLibraryModel.items
	self.noteChartSetItemIndex = self.game.noteChartSetLibraryModel:getItemIndex(
		self.config.noteChartDataEntryId,
		self.config.noteChartEntryId,
		self.config.noteChartSetEntryId
	)

	if not noUpdate then
		self.noteChartSetStateCounter = self.noteChartSetStateCounter + 1
	end

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.noteChartSetItem = noteChartSetItem
	if noteChartSetItem then
		self.config.noteChartSetEntryId = noteChartSetItem.setId
		self.pullingNoteChartSet = false
		return self:pullNoteChart(noUpdate)
	end

	self.config.noteChartSetEntryId = 0
	self.config.noteChartEntryId = 0
	self.config.noteChartDataEntryId = 0

	self.noteChartItem = nil
	self.scoreItem = nil

	self.game.noteChartLibraryModel:clear()
	self.game.scoreLibraryModel:clear()

	self.pullingNoteChartSet = false
end

SelectModel.pullNoteChart = function(self, noUpdate)
	self.game.noteChartLibraryModel:setNoteChartSetId(self.config.noteChartSetEntryId)

	local noteChartItems = self.game.noteChartLibraryModel.items
	self.noteChartItemIndex = self.game.noteChartLibraryModel:getItemIndex(
		self.config.noteChartDataEntryId,
		self.config.noteChartEntryId,
		self.config.noteChartSetEntryId
	)

	if not noUpdate then
		self.noteChartStateCounter = self.noteChartStateCounter + 1
	end

	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem
	if noteChartItem then
		self.config.noteChartEntryId = noteChartItem.noteChartId
		self.config.noteChartDataEntryId = noteChartItem.noteChartDataId
		return self:pullScore(noUpdate)
	end

	self.config.noteChartEntryId = 0
	self.config.noteChartDataEntryId = 0

	self.scoreItem = nil

	self.game.scoreLibraryModel:clear()
end

SelectModel.pullScore = function(self, noUpdate)
	local noteChartItems = self.game.noteChartLibraryModel.items
	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	if not noteChartItem then
		return
	end

	if not noUpdate then
		self.game.scoreLibraryModel:setHash(noteChartItem.hash)
		self.game.scoreLibraryModel:setIndex(noteChartItem.index)
		self.game.scoreLibraryModel:updateItems()
	end

	local scoreItems = self.game.scoreLibraryModel.items
	self.scoreItemIndex = self.game.scoreLibraryModel:getItemIndex(self.config.scoreEntryId)

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem
	if scoreItem then
		self.config.scoreEntryId = scoreItem.id
	end
end

return SelectModel
