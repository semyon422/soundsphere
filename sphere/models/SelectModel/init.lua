local class = require("class")
local delay = require("delay")
local thread = require("thread")
local path_util = require("path_util")
local NoteChartFactory = require("notechart.NoteChartFactory")
local NoteChartLibrary = require("sphere.models.SelectModel.NoteChartLibrary")
local NoteChartSetLibrary = require("sphere.models.SelectModel.NoteChartSetLibrary")
local CollectionLibrary = require("sphere.models.SelectModel.CollectionLibrary")
local SearchModel = require("sphere.models.SelectModel.SearchModel")
local SortModel = require("sphere.models.SelectModel.SortModel")
local Orm = require("sphere.Orm")

---@class sphere.SelectModel
---@operator call: sphere.SelectModel
local SelectModel = class()

SelectModel.noteChartSetItemIndex = 1
SelectModel.noteChartItemIndex = 1
SelectModel.scoreItemIndex = 1
SelectModel.pullingNoteChartSet = false
SelectModel.debounceTime = 0.5

function SelectModel:new()
	self.noteChartLibrary = NoteChartLibrary()
	self.noteChartSetLibrary = NoteChartSetLibrary()
	self.collectionLibrary = CollectionLibrary()
	self.searchModel = SearchModel()
	self.sortModel = SortModel()
end

function SelectModel:load()
	local config = self.configModel.configs.select
	self.config = config

	self.noteChartLibrary.cacheModel = self.cacheModel
	self.noteChartSetLibrary.cacheModel = self.cacheModel
	self.searchModel.configModel = self.configModel
	self.collectionLibrary.cacheModel = self.cacheModel
	self.collectionLibrary.configModel = self.configModel

	self.searchMode = config.searchMode

	self.noteChartSetStateCounter = 1
	self.noteChartStateCounter = 1
	self.scoreStateCounter = 1

	self.collectionLibrary:load()

	self.collectionItemIndex = self.collectionLibrary:getItemIndex(config.collection)
	self.collectionItem = self.collectionLibrary.items[self.collectionItemIndex]

	self:noDebouncePullNoteChartSet()
end

function SelectModel:updateSetItems()
	local params = self.cacheModel.cacheDatabase.queryParams

	local orderBy, isCollapseAllowed = self.sortModel:getOrder(self.config.sortFunction)
	local fields = {}
	for i, field in ipairs(orderBy) do
		fields[i] = field .. " ASC"
	end
	table.insert(fields, "noteChartDatas.id ASC")
	params.orderBy = table.concat(fields, ",")

	if self.config.collapse and isCollapseAllowed then
		params.groupBy = "noteCharts.setId"
	else
		params.groupBy = nil
	end

	local where, lamp = self.searchModel:getConditions()

	where.path__startswith = self.collectionItem.path .. "/"

	params.where = Orm:build_condition(where)
	params.lamp = lamp and Orm:build_condition(lamp)

	self.cacheModel.cacheDatabase:asyncQueryAll()

	self.noteChartSetLibrary:updateItems()
end

---@param hash string
---@param index number
function SelectModel:findNotechart(hash, index)
	local params = self.cacheModel.cacheDatabase.queryParams

	params.groupBy = nil
	params.lamp = nil
	params.where = ("noteChartDatas.hash = %q AND noteChartDatas.`index` = %d"):format(hash, index)

	self.cacheModel.cacheDatabase:asyncQueryAll()

	self.noteChartSetLibrary:updateItems()
end

---@return string?
function SelectModel:getBackgroundPath()
	local chart = self.noteChartItem
	if not chart then
		return
	end

	local path = chart.path
	local stagePath = chart.stagePath
	if not path or not stagePath then
		return
	end

	if path:find("%.ojn$") or path:find("%.mid$") then
		return path
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""

	if stagePath and stagePath ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. stagePath)
	end

	return directoryPath
end

---@return string?
---@return number?
function SelectModel:getAudioPathPreview()
	local chart = self.noteChartItem
	if not chart then
		return
	end

	local path = chart.path
	local audioPath = chart.audioPath
	if not path or not audioPath then
		return
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""

	if audioPath and audioPath ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. audioPath), math.max(0, self.previewTime or 0)
	end

	return directoryPath .. "/preview.ogg", 0
end

function SelectModel:loadNoteChart(settings)
	local chart = self.noteChartItem

	local content = love.filesystem.read(chart.path)
	if not content then
		return
	end

	local status, noteCharts = NoteChartFactory:getNoteCharts(
		chart.path,
		content,
		chart.index,
		settings
	)
	assert(status, noteCharts)

	return noteCharts[1]
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
function SelectModel:setSortFunction(sortFunctionName)
	if self.pullingNoteChartSet then
		return
	end
	self.config.sortFunction = sortFunctionName
	self:noDebouncePullNoteChartSet()
end

function SelectModel:changeCollapse()
	if self.pullingNoteChartSet then
		return
	end
	self.config.collapse = not self.config.collapse
	self:noDebouncePullNoteChartSet()
end

---@param locked boolean
function SelectModel:setLock(locked)
	self.locked = locked
end

---@param direction number?
---@param destination number?
function SelectModel:scrollCollection(direction, destination)
	if self.pullingNoteChartSet then
		return
	end

	local collectionItems = self.collectionLibrary.items

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
		self:updateSetItems()
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
