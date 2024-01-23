local class = require("class")
local delay = require("delay")
local thread = require("thread")
local path_util = require("path_util")
local table_util = require("table_util")
local NoteChartFactory = require("notechart.NoteChartFactory")
local NoteChartLibrary = require("sphere.models.SelectModel.NoteChartLibrary")
local NoteChartSetLibrary = require("sphere.models.SelectModel.NoteChartSetLibrary")
local CollectionLibrary = require("sphere.models.SelectModel.CollectionLibrary")
local SearchModel = require("sphere.models.SelectModel.SearchModel")
local SortModel = require("sphere.models.SelectModel.SortModel")

---@class sphere.SelectModel
---@operator call: sphere.SelectModel
local SelectModel = class()

SelectModel.noteChartSetItemIndex = 1
SelectModel.noteChartItemIndex = 1
SelectModel.scoreItemIndex = 1
SelectModel.pullingNoteChartSet = false
SelectModel.debounceTime = 0.5

---@param configModel sphere.ConfigModel
---@param scoreLibraryModel sphere.ScoreLibraryModel
---@param cacheModel sphere.CacheModel
function SelectModel:new(configModel, scoreLibraryModel, cacheModel)
	self.configModel = configModel
	self.scoreLibraryModel = scoreLibraryModel
	self.cacheModel = cacheModel

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
	local params = {}

	local order, group_allowed = self.sortModel:getOrder(self.config.sortFunction)

	params.order = table_util.copy(order)
	table.insert(params.order, "chartmeta_id")

	if self.config.collapse and group_allowed then
		params.group = {"chartfile_set_id"}
	end

	local where, lamp = self.searchModel:getConditions()
	where.path__startswith = self.collectionItem.path .. "/"

	params.where = where
	params.lamp = lamp

	self.cacheModel.cacheDatabase:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
end

---@param hash string
---@param index number
function SelectModel:findNotechart(hash, index)
	local params = {where = {hash = hash, index = index}}
	self.cacheModel.cacheDatabase:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
end

---@return string?
function SelectModel:getBackgroundPath()
	local chart = self.noteChartItem
	if not chart then
		return
	end

	local path = chart.path
	local background_path = chart.background_path
	if not path or not background_path then
		return
	end

	if path:find("%.ojn$") or path:find("%.mid$") then
		return path
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""

	if background_path and background_path ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. background_path)
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
	local audio_path = chart.audio_path
	if not path or not audio_path then
		return
	end

	local directoryPath = path:match("^(.+)/(.-)$") or ""

	if audio_path and audio_path ~= "" then
		return path_util.eval_path(directoryPath .. "/" .. audio_path), math.max(0, tonumber(chart.preview_time) or 0)
	end

	return directoryPath .. "/preview.ogg", 0
end

---@param settings table?
---@return ncdk.NoteChart?
function SelectModel:loadNoteChart(settings)
	local chart = self.noteChartItem

	local content = love.filesystem.read(chart.path)
	if not content then
		return
	end

	return assert(NoteChartFactory:getNoteChart(
		chart.path,
		content,
		chart.index,
		settings
	))
end

---@return boolean
function SelectModel:isChanged()
	local changed = self.changed
	self.changed = false
	return changed == true
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
	self.config.chartfile_set_id = item.chartfile_set_id
	self.config.chartfile_id = item.chartfile_id
	self.config.chartmeta_id = item.chartmeta_id
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

	self:pullNoteChart(oldNoteChartSetItem and oldNoteChartSetItem.chartfile_set_id == noteChartSetItem.chartfile_set_id)
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

	self.config.score_id = scoreItem.id
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
		self.config.chartfile_id,
		self.config.chartmeta_id,
		self.config.chartfile_set_id
	)

	if not noUpdate then
		self.noteChartSetStateCounter = self.noteChartSetStateCounter + 1
	end

	local noteChartSetItem = noteChartSetItems[self.noteChartSetItemIndex]
	self.noteChartSetItem = noteChartSetItem
	if noteChartSetItem then
		self.config.chartfile_set_id = noteChartSetItem.chartfile_set_id
		self.pullingNoteChartSet = false
		if not noPullNext then
			self:pullNoteChart(noUpdate)
		end
		return
	end

	self.config.chartfile_set_id = 0
	self.config.chartfile_id = 0
	self.config.chartmeta_id = 0

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

	self.noteChartLibrary:setNoteChartSetId(self.config.chartfile_set_id)

	local noteChartItems = self.noteChartLibrary.items
	self.noteChartItemIndex = self.noteChartLibrary:getItemIndex(
		self.config.chartfile_id,
		self.config.chartmeta_id
	)

	if not noUpdate then
		self.noteChartStateCounter = self.noteChartStateCounter + 1
	end
	local noteChartItem = noteChartItems[self.noteChartItemIndex]
	self.noteChartItem = noteChartItem
	self.changed = true

	if noteChartItem then
		self.config.chartfile_id = noteChartItem.chartfile_id
		self.config.chartmeta_id = noteChartItem.chartmeta_id
		if not noPullNext then
			self:pullScore(oldId and oldId == noteChartItem.id)
		end
		return
	end

	self.config.chartfile_id = 0
	self.config.chartmeta_id = 0

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
	self.scoreItemIndex = self.scoreLibraryModel:getItemIndex(self.config.score_id) or 1

	local scoreItem = scoreItems[self.scoreItemIndex]
	self.scoreItem = scoreItem
	if scoreItem then
		self.config.score_id = scoreItem.id
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
