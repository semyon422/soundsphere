local class = require("class")
local delay = require("delay")
local thread = require("thread")
local path_util = require("path_util")
local table_util = require("table_util")
local NoteChartFactory = require("notechart.NoteChartFactory")
local NoteChartLibrary = require("sphere.models.SelectModel.NoteChartLibrary")
local NoteChartSetLibrary = require("sphere.models.SelectModel.NoteChartSetLibrary")
local CollectionLibrary = require("sphere.models.SelectModel.CollectionLibrary")
local ScoreLibrary = require("sphere.models.SelectModel.ScoreLibrary")
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
---@param cacheModel sphere.CacheModel
---@param onlineModel sphere.OnlineModel
function SelectModel:new(configModel, cacheModel, onlineModel)
	self.configModel = configModel
	self.cacheModel = cacheModel

	self.noteChartLibrary = NoteChartLibrary(cacheModel)
	self.noteChartSetLibrary = NoteChartSetLibrary(cacheModel)
	self.collectionLibrary = CollectionLibrary(cacheModel, configModel)
	self.searchModel = SearchModel(configModel)
	self.sortModel = SortModel()

	self.scoreLibrary = ScoreLibrary(
		configModel,
		onlineModel,
		cacheModel
	)
end

function SelectModel:load()
	local config = self.configModel.configs.select
	self.config = config

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
	local config = self.configModel.configs.settings.select

	local params = {}

	local order, group_allowed = self.sortModel:getOrder(self.config.sortFunction)

	params.order = table_util.copy(order)
	table.insert(params.order, "chartmeta_id")

	if config.collapse and group_allowed then
		params.group = {"chartfile_set_id"}
	end

	local where, lamp = self.searchModel:getConditions()

	local path = self.collectionItem.path
	if path then
		where.path__startswith = path
	end

	params.where = where
	params.lamp = lamp
	params.difficulty = config.diff_column

	self.cacheModel.cacheDatabase:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
end

---@param hash string
---@param index number
function SelectModel:findNotechart(hash, index)
	local config = self.configModel.configs.settings.select
	local params = {
		where = {hash = hash, index = index},
		difficulty = config.diff_column,
	}
	self.cacheModel.cacheDatabase:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
end

---@return string?
function SelectModel:getBackgroundPath()
	local chart = self.noteChartItem
	if not chart then
		return
	end

	local background_path = chart.background_path
	if not background_path or background_path == "" then
		return
	end

	local name = chart.name
	if name:find("%.ojn$") or name:find("%.mid$") then
		return chart.path
	end

	return path_util.join(chart.location_dir, background_path)
end

---@return string?
---@return number?
function SelectModel:getAudioPathPreview()
	local chart = self.noteChartItem
	if not chart then
		return
	end

	local audio_path = chart.audio_path
	if not audio_path or audio_path == "" then
		return path_util.join(chart.location_dir, "preview.ogg"), 0
	end

	local preview_time = math.max(0, tonumber(chart.preview_time) or 0)
	return path_util.join(chart.location_dir, audio_path), preview_time
end

---@param settings table?
---@return ncdk.NoteChart?
function SelectModel:loadNoteChart(settings)
	local chart = self.noteChartItem

	local content = love.filesystem.read(chart.location_path)
	if not content then
		return
	end

	return assert(NoteChartFactory:getNoteChart(
		chart.chartfile_name,
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
	local chart = self.noteChartItem
	if chart then
		return love.filesystem.getInfo(chart.location_path) ~= nil
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
	local items = self.noteChartSetLibrary.items
	local destination = math.random(1, #items)
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
	local items = self.noteChartSetLibrary.items

	destination = math.min(math.max(destination or self.noteChartSetItemIndex + direction, 1), #items)
	if not items[destination] or self.noteChartSetItemIndex == destination then
		return
	end
	self.noteChartSetItemIndex = destination

	local oldNoteChartSetItem = self.noteChartSetItem

	local noteChartSetItem = items[self.noteChartSetItemIndex]
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
	local scoreItems = self.scoreLibrary.items

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
	self.scoreLibrary:clear()

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

	self.scoreLibrary:clear()
end

function SelectModel:updateScoreOnlineAsync()
	self.scoreLibrary:updateItemsAsync(self.noteChartItem)
	self:findScore()
end

SelectModel.updateScoreOnline = thread.coro(SelectModel.updateScoreOnlineAsync)

function SelectModel:findScore()
	local scoreItems = self.scoreLibrary.items
	self.scoreItemIndex = self.scoreLibrary:getItemIndex(self.config.score_id) or 1

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
		self.scoreLibrary:setHash(noteChartItem.hash)
		self.scoreLibrary:setIndex(noteChartItem.index)

		local select = self.configModel.configs.select
		if select.scoreSourceName == "online" then
			self.scoreLibrary:clear()
			delay.debounce(self, "scoreDebounce", self.debounceTime,
				self.updateScoreOnlineAsync, self
			)
			return
		end
		self.scoreLibrary:updateItems(self.noteChartItem)
	end

	self:findScore()
end

return SelectModel
