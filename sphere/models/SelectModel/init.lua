local class = require("class")
local delay = require("delay")
local thread = require("thread")
local NoteChartLibrary = require("sphere.models.SelectModel.NoteChartLibrary")
local NoteChartSetLibrary = require("sphere.models.SelectModel.NoteChartSetLibrary")
local SearchModel = require("sphere.models.SelectModel.SearchModel")
local SortModel = require("sphere.models.SelectModel.SortModel")

---@class sphere.SelectModel
---@operator call: sphere.SelectModel
local SelectModel = class()

function SelectModel:new()
	self.noteChartSetItemIndex = 1
	self.noteChartItemIndex = 1
	self.scoreItemIndex = 1
	self.pullingNoteChartSet = false
	self.noteChartLibrary = NoteChartLibrary()
	self.noteChartSetLibrary = NoteChartSetLibrary()
	self.searchModel = SearchModel()
	self.sortModel = SortModel()
end

SelectModel.debounceTime = 0.5

function SelectModel:load()
	local config = self.configModel.configs.select
	self.config = config

	self.noteChartLibrary.cacheModel = self.cacheModel
	self.noteChartSetLibrary.cacheModel = self.cacheModel
	self.noteChartSetLibrary.sortModel = self.sortModel
	self.noteChartSetLibrary.searchModel = self.searchModel
	self.searchModel.configModel = self.configModel

	self.searchModel:setFilterString(config.filterString)
	self.searchModel:setLampString(config.lampString)
	self.searchMode = config.searchMode
	self.sortModel.name = config.sortFunction
	self.noteChartSetLibrary.collapse = config.collapse

	self.noteChartSetStateCounter = 1
	self.noteChartStateCounter = 1
	self.scoreStateCounter = 1
	self.searchStateCounter = self.searchModel.stateCounter

	self.collectionItemIndex = self.collectionModel:getItemIndex(config.collection)
	self.collectionItem = self.collectionModel.items[self.collectionItemIndex]

	self:noDebouncePullNoteChartSet()
end

---@return boolean
function SelectModel:isChanged()
	local changed = self.changed
	self.changed = false
	return changed
end

function SelectModel:setChanged()
	self.changed = true
end

---@return boolean
function SelectModel:notechartExists()
	local noteChartItem = self.noteChartItem
	if noteChartItem then
		return love.filesystem.getInfo(noteChartItem.path) ~= nil
	end
	return false
end

---@return boolean
function SelectModel:isPlayed()
	return not not (self:notechartExists() and self.scoreItem)
end

---@param ... any?
function SelectModel:debouncePullNoteChartSet(...)
	delay.debounce(self, "pullNoteChartSetDebounce", self.debounceTime, self.pullNoteChartSet, self, ...)
end

SelectModel.noDebouncePullNoteChartSet = thread.coro(function(self, ...)
	self:pullNoteChartSet(...)
end)

---@param sortFunctionName string
---@param noDebounce boolean?
function SelectModel:setSortFunction(sortFunctionName, noDebounce)
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.sortFunction = sortFunctionName
	self.sortModel.name = sortFunctionName
	if noDebounce then
		self:noDebouncePullNoteChartSet()
		return
	end
	self:debouncePullNoteChartSet()
end

function SelectModel:changeCollapse()
	if self.pullingNoteChartSet then
		return
	end
	local config = self.config
	config.collapse = not config.collapse
	self.noteChartSetLibrary.collapse = config.collapse
	self:debouncePullNoteChartSet()
end

---@param locked boolean
function SelectModel:setLock(locked)
	self.locked = locked
end

function SelectModel:update()
	local stateCounter = self.searchModel.stateCounter
	if self.searchStateCounter == stateCounter or self.pullingNoteChartSet then
		return
	end
	self.config.filterString = self.searchModel.filterString
	self.config.lampString = self.searchModel.lampString
	self.searchStateCounter = stateCounter
	self:debouncePullNoteChartSet()
end

---@param direction number?
---@param destination number?
function SelectModel:scrollCollection(direction, destination)
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

function SelectModel:scrollRandom()
	local noteChartSetItems = self.noteChartSetLibrary.items

	local destination = math.random(1, #noteChartSetItems)

	self:scrollNoteChartSet(nil, destination)
end

---@param item table
function SelectModel:setConfig(item)
	self.config.noteChartSetEntryId = item.setId
	self.config.noteChartEntryId = item.noteChartId
	self.config.noteChartDataEntryId = item.noteChartDataId
end

---@param direction number?
---@param destination number?
function SelectModel:scrollNoteChartSet(direction, destination)
	local noteChartSetItems = self.noteChartSetLibrary.items

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

---@param direction number?
---@param destination number?
function SelectModel:scrollNoteChart(direction, destination)
	local noteChartItems = self.noteChartLibrary.items

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

---@param direction number?
---@param destination number?
function SelectModel:scrollScore(direction, destination)
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

---@param noUpdate boolean?
---@param noPullNext boolean?
function SelectModel:pullNoteChartSet(noUpdate, noPullNext)
	if self.locked then
		return
	end

	self.pullingNoteChartSet = true

	if not noUpdate then
		self.searchModel:setCollection(self.collectionItem)
		self.noteChartSetLibrary:updateItems()
	end

	local noteChartSetItems = self.noteChartSetLibrary.items
	self.noteChartSetItemIndex = self.noteChartSetLibrary:getItemIndex(
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

	self.noteChartLibrary:clear()
	self.scoreLibraryModel:clear()

	self.pullingNoteChartSet = false
end

---@param noUpdate boolean?
---@param noPullNext boolean?
function SelectModel:pullNoteChart(noUpdate, noPullNext)
	local oldId = self.noteChartItem and self.noteChartItem.id

	self.noteChartLibrary:setNoteChartSetId(self.config.noteChartSetEntryId)

	local noteChartItems = self.noteChartLibrary.items
	self.noteChartItemIndex = self.noteChartLibrary:getItemIndex(
		self.config.noteChartEntryId
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

function SelectModel:updateScoreOnlineAsync()
	self.scoreLibraryModel:updateItemsAsync()
	self:findScore()
end

SelectModel.updateScoreOnline = thread.coro(SelectModel.updateScoreOnlineAsync)

function SelectModel:findScore()
	local scoreItems = self.scoreLibraryModel.items
	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(self.config.scoreEntryId) or 1

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem
	if scoreItem then
		self.config.scoreEntryId = scoreItem.id
	end
end

---@param noUpdate boolean?
function SelectModel:pullScore(noUpdate)
	local noteChartItems = self.noteChartLibrary.items
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
