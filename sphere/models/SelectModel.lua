local Class = require("Class")
local delay = require("delay")
local thread = require("thread")

local SelectModel = Class:new()

SelectModel.construct = function(self)
	self.noteChartSetItemIndex = 1
	self.noteChartItemIndex = 1
	self.scoreItemIndex = 1
	self.pullingNoteChartSet = false
end

SelectModel.debounceTime = 0.5

SelectModel.load = function(self)
	local config = self.configModel.configs.select
	self.config = config

	self.searchModel:setFilterString(config.filterString)
	self.searchModel:setLampString(config.lampString)
	self.searchMode = config.searchMode
	self.sortModel.name = config.sortFunction
	self.noteChartSetLibraryModel.collapse = config.collapse

	self.noteChartSetStateCounter = 1
	self.noteChartStateCounter = 1
	self.scoreStateCounter = 1
	self.searchStateCounter = self.searchModel.stateCounter

	self.collectionItemIndex = self.collectionModel:getItemIndex(config.collection)
	self.collectionItem = self.collectionModel.items[self.collectionItemIndex]

	self:noDebouncePullNoteChartSet()
end

SelectModel.isChanged = function(self)
	local changed = self.changed
	self.changed = false
	return changed
end

SelectModel.setChanged = function(self)
	self.changed = true
end

SelectModel.notechartExists = function(self)
	local noteChartItem = self.noteChartItem
	if noteChartItem then
		return love.filesystem.getInfo(noteChartItem.path)
	end
end

SelectModel.isPlayed = function(self)
	return self:notechartExists() and self.scoreItem
end

SelectModel.debouncePullNoteChartSet = function(self, ...)
	delay.debounce(self, "pullNoteChartSetDebounce", self.debounceTime, self.pullNoteChartSet, self, ...)
end

SelectModel.noDebouncePullNoteChartSet = thread.coro(function(self, ...)
	self:pullNoteChartSet(...)
end)

SelectModel.setSortFunction = function(self, sortFunctionName, noDebounce)
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.sortFunction = sortFunctionName
	self.sortModel.name = sortFunctionName
	if noDebounce then
		return self:noDebouncePullNoteChartSet()
	end
	self:debouncePullNoteChartSet()
end

SelectModel.changeCollapse = function(self)
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.collapse = not config.collapse
	self.noteChartSetLibraryModel.collapse = config.collapse
	self:debouncePullNoteChartSet()
end

SelectModel.update = function(self)
	local stateCounter = self.searchModel.stateCounter
	if self.searchStateCounter == stateCounter or self.pullingNoteChartSet then
		return
	end
	self.config.filterString = self.searchModel.filterString
	self.config.lampString = self.searchModel.lampString
	self.searchStateCounter = stateCounter
	self:debouncePullNoteChartSet()
end

SelectModel.scrollCollection = function(self, direction, destination)
	if self.pullingNoteChartSet then
		return
	end

	local collectionItems = self.collectionModel.items

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
	local noteChartSetItems = self.noteChartSetLibraryModel.items

	local destination = math.random(1, #noteChartSetItems)

	self:scrollNoteChartSet(nil, destination)
end

SelectModel.setConfig = function(self, item)
	self.config.noteChartSetEntryId = item.setId
	self.config.noteChartEntryId = item.noteChartId
	self.config.noteChartDataEntryId = item.noteChartDataId
end

SelectModel.scrollNoteChartSet = function(self, direction, destination)
	local noteChartSetItems = self.noteChartSetLibraryModel.items

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
	local noteChartItems = self.noteChartLibraryModel.items

	direction = direction or destination - self.noteChartItemIndex

	destination = math.min(math.max(destination or self.noteChartItemIndex + direction, 1), #noteChartItems)
	if not noteChartItems[destination] or self.noteChartItemIndex == destination then
		return
	end
	self.noteChartItemIndex = destination

	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem
	self.changed = true

	self:setConfig(noteChartItem)

	self:pullNoteChartSet(true, true)
	self:pullScore()
end

SelectModel.scrollScore = function(self, direction, destination)
	local scoreItems = self.scoreLibraryModel.items

	destination = math.min(math.max(destination or self.scoreItemIndex + direction, 1), #scoreItems)
	if not scoreItems[destination] or self.scoreItemIndex == destination then
		return
	end
	self.scoreItemIndex = destination

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem

	self.config.scoreEntryId = scoreItem.id
end

SelectModel.pullNoteChartSet = function(self, noUpdate, noPullNext)
	self.pullingNoteChartSet = true

	if not noUpdate then
		self.searchModel:setCollection(self.collectionItem)
		self.noteChartSetLibraryModel:updateItems()
	end

	local noteChartSetItems = self.noteChartSetLibraryModel.items
	self.noteChartSetItemIndex = self.noteChartSetLibraryModel:getItemIndex(
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
		if not noPullNext then
			self:pullNoteChart(noUpdate)
		end
		return
	end

	self.config.noteChartSetEntryId = 0
	self.config.noteChartEntryId = 0
	self.config.noteChartDataEntryId = 0

	self.noteChartItem = nil
	self.scoreItem = nil
	self.changed = true

	self.noteChartLibraryModel:clear()
	self.scoreLibraryModel:clear()

	self.pullingNoteChartSet = false
end

SelectModel.pullNoteChart = function(self, noUpdate, noPullNext)
	local oldId = self.noteChartItem and self.noteChartItem.id

	self.noteChartLibraryModel:setNoteChartSetId(self.config.noteChartSetEntryId)

	local noteChartItems = self.noteChartLibraryModel.items
	self.noteChartItemIndex = self.noteChartLibraryModel:getItemIndex(
		self.config.noteChartDataEntryId,
		self.config.noteChartEntryId,
		self.config.noteChartSetEntryId
	)

	if not noUpdate then
		self.noteChartStateCounter = self.noteChartStateCounter + 1
	end
	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem
	self.changed = true

	if noteChartItem then
		self.config.noteChartEntryId = noteChartItem.noteChartId
		self.config.noteChartDataEntryId = noteChartItem.noteChartDataId
		if not noPullNext then
			self:pullScore(oldId and oldId == noteChartItem.id)
		end
		return
	end

	self.config.noteChartEntryId = 0
	self.config.noteChartDataEntryId = 0

	self.scoreItem = nil

	self.scoreLibraryModel:clear()
end

SelectModel.updateScoreOnlineAsync = function(self)
	self.scoreLibraryModel:updateItemsAsync()
	self:findScore()
end

SelectModel.updateScoreOnline = thread.coro(SelectModel.updateScoreOnlineAsync)

SelectModel.findScore = function(self)
	local scoreItems = self.scoreLibraryModel.items
	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(self.config.scoreEntryId) or 1

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem
	if scoreItem then
		self.config.scoreEntryId = scoreItem.id
	end
end

SelectModel.pullScore = function(self, noUpdate)
	local noteChartItems = self.noteChartLibraryModel.items
	local noteChartItem = noteChartItems[self.noteChartItemIndex]

	if not noteChartItem then
		return
	end

	if not noUpdate then
		self.scoreStateCounter = self.scoreStateCounter + 1
		self.scoreLibraryModel:setHash(noteChartItem.hash)
		self.scoreLibraryModel:setIndex(noteChartItem.index)

		local select = self.configModel.configs.select
		if select.scoreSourceName == "online" then
			self.scoreLibraryModel:clear()
			delay.debounce(self, "scoreDebounce", self.debounceTime,
				self.updateScoreOnlineAsync, self
			)
			return
		end
		self.scoreLibraryModel:updateItems()
	end

	self:findScore()
end

return SelectModel
