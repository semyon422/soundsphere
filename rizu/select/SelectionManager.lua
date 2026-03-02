local class = require("class")
local delay = require("delay")
local thread = require("thread")
local path_util = require("path_util")
local table_util = require("table_util")
local Observable = require("aqua.Observable")
local ChartFactory = require("notechart.ChartFactory")
local SelectionState = require("rizu.select.SelectionState")
local ChartStore = require("rizu.select.stores.ChartStore")
local ChartSetStore = require("rizu.select.stores.ChartSetStore")
local CollectionStore = require("rizu.select.stores.CollectionStore")
local ScoreStore = require("rizu.select.stores.ScoreStore")
local SearchModel = require("rizu.select.SearchModel")
local SortModel = require("rizu.select.SortModel")
local FilterModel = require("rizu.select.FilterModel")
local SelectionQueryBuilder = require("rizu.select.SelectionQueryBuilder")
local ChartMetadataService = require("rizu.select.services.ChartMetadataService")
local TaskRunner = require("rizu.select.tasks.TaskRunner")
local LocalScoreProvider = require("rizu.select.providers.LocalScoreProvider")
local OnlineScoreProvider = require("rizu.select.providers.OnlineScoreProvider")

---@class rizu.select.SelectionManager
---@operator call: rizu.select.SelectionManager
local SelectionManager = class()

SelectionManager.debounceTime = 0.5

---@param configModel sphere.ConfigModel
---@param library rizu.library.Library
---@param fs fs.IFilesystem
---@param onlineModel sphere.OnlineModel
---@param replayBase sea.ReplayBase
---@param state? rizu.select.SelectionState
function SelectionManager:new(configModel, library, fs, onlineModel, replayBase, state)
	self.configModel = configModel
	self.library = library
	self.fs = fs
	self.onlineModel = onlineModel
	self.replayBase = replayBase
	self.state = state or SelectionState()

	self.chartStore = ChartStore(library)
	self.chartSetStore = ChartSetStore(library)
	self.collectionStore = CollectionStore(library)
	self.searchModel = SearchModel(configModel)
	self.filterModel = FilterModel(configModel)
	self.sortModel = SortModel()
	self.queryBuilder = SelectionQueryBuilder(configModel, self.sortModel, self.searchModel, self.filterModel)
	self.metadataService = ChartMetadataService(fs)
	self.taskRunner = TaskRunner()

	local localProvider = LocalScoreProvider(library)
	local onlineProvider = OnlineScoreProvider(onlineModel)
	self.scoreStore = ScoreStore(
		configModel,
		localProvider,
		onlineProvider
	)

	-- Backward compatibility
	self.noteChartLibrary = self.chartStore
	self.noteChartSetLibrary = self.chartSetStore
	self.collectionLibrary = self.collectionStore
	self.scoreLibrary = self.scoreStore

	self.onChanged = Observable()
	self.state.onChanged:add(self)
end
function SelectionManager:receive(event)
	if event.type == "set" then
		self.taskRunner:push(function()
			self:pullNoteChart()
		end, 1)
	elseif event.type == "chart" then
		self.taskRunner:push(function()
			self:pullScore()
			local index = self.chartSetStore:indexof(self.config)
			local chartview_set = self.chartSetStore:get(index)
			self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)
		end, 2)
	end
end

function SelectionManager:load()
	local settings = self.configModel.configs.settings
	local config = self.configModel.configs.select
	self.config = config

	self.searchMode = config.searchMode

	self.collectionStore:load(settings.select.locations_in_collections)
	self.collectionStore:setPath(config.collection, config.location_id)

	self.filterModel:apply()

	self:noDebouncePullNoteChartSet()
end

function SelectionManager:updateSetItems()
	local collectionStore = self.collectionStore
	local collectionItem = collectionStore.tree.items[collectionStore.tree.selected]
	local params = self.queryBuilder:build(self.config, collectionItem)

	self.library.chartviewsRepo:queryAsync(params)
	self.chartSetStore:updateItems()
	self.onChanged:send({type = "update_set_items"})
end

---@param hash string
---@param index number
function SelectionManager:findNotechart(hash, index)
	local config = self.configModel.configs.settings.select
	local params = {
		where = {hash = hash, index = index},
		difficulty = config.diff_column,
	}
	self.taskRunner:push(function()
		self.library.chartviewsRepo:queryAsync(params)
		self.chartSetStore:updateItems()
		local chartview_set = self.chartSetStore:get(1)
		if chartview_set then
			self.chartStore:setNoteChartSetId(chartview_set)
		end
		self.onChanged:send({type = "find_notechart", hash = hash, index = index})
	end, 1)
end

---@return string?
function SelectionManager:getBackgroundPath()
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:getBackgroundPath(chartview)
end

---@return string?
---@return number?
---@return string?
function SelectionManager:getAudioPathPreview()
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:getAudioPathPreview(chartview)
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function SelectionManager:loadChart(settings)
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:loadChart(chartview)
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function SelectionManager:loadChartAbsolute(settings)
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:loadChartAbsolute(chartview)
end

---@return boolean
function SelectionManager:isChanged()
	local changed = self.changed
	self.changed = false
	return changed == true
end

function SelectionManager:setChanged()
	self.changed = true
	self.onChanged:send({type = "set_changed"})
end

---@return boolean
function SelectionManager:notechartExists()
	local chartview = self.chartview
	if chartview then
		return self.fs:getInfo(chartview.location_path) ~= nil
	end
	return false
end

---@return boolean
function SelectionManager:isPlayed()
	return not not (self:notechartExists() and self.scoreItem)
end

---@param ... any?
function SelectionManager:debouncePullNoteChartSet(...)
	delay.debounce(self, "pullNoteChartSetDebounce", self.debounceTime, self.pullNoteChartSet, self, ...)
end

function SelectionManager:noDebouncePullNoteChartSet(...)
	local args = {...}
	self.taskRunner:push(function()
		self:pullNoteChartSet(unpack(args))
		if self.chartview then
			self:setConfig(self.chartview)
		end
	end, 1)
end

---@param sortFunctionName string
function SelectionManager:setSortFunction(sortFunctionName)
	self.config.sortFunction = sortFunctionName
	self:noDebouncePullNoteChartSet()
end

---@param locked boolean
function SelectionManager:setLock(locked)
	self.locked = locked
end

---@param direction number?
---@param destination number?
---@param force boolean?
function SelectionManager:scrollCollection(direction, destination, force)
	local collectionStore = self.collectionStore
	local items = collectionStore.tree.items
	local selected = collectionStore.tree.selected

	destination = math.min(math.max(destination or selected + direction, 1), #items)
	if not items[destination] or not force and selected == destination then
		return
	end

	local old_item = items[collectionStore.tree.selected]

	collectionStore.tree.selected = destination

	local item = items[destination]
	self.config.collection = item.path
	self.config.location_id = item.location_id

	self:debouncePullNoteChartSet(old_item and old_item.path == item.path)
end

function SelectionManager:scrollRandom()
	local itemsCount = self.chartSetStore:count()
	local destination = math.random(1, itemsCount)
	self:scrollNoteChartSet(nil, destination)
end

---@param chartview table
function SelectionManager:setConfig(chartview)
	self.config.chartfile_set_id = chartview.chartfile_set_id
	self.config.chartfile_id = chartview.chartfile_id
	self.config.chartmeta_id = chartview.chartmeta_id
	self.config.chartdiff_id = chartview.chartdiff_id
	self.config.chartplay_id = chartview.chartplay_id
	self.config.select_chartplay_id = chartview.chartplay_id

	local config = self.configModel.configs.settings.select

	local views = config.chartviews_table
	if views == "chartviews" then
		return
	end

	local replayBase = self.replayBase

	replayBase.modifiers = chartview.modifiers or {}
	replayBase.rate = chartview.rate or 1
	replayBase.mode = chartview.mode or "mania"

	if views == "chartdiffviews" then
		return
	end

	replayBase.nearest = chartview.nearest or false
	replayBase.tap_only = chartview.tap_only or false
	replayBase.timings = chartview.timings
	replayBase.subtimings = chartview.subtimings
	replayBase.columns_order = chartview.columns_order
	replayBase.custom = chartview.custom or false
	replayBase.const = chartview.const or false
	replayBase.rate_type = chartview.rate_type or "linear"
end

---@param direction number?
---@param destination number?
function SelectionManager:scrollNoteChartSet(direction, destination)
	local itemsCount = self.chartSetStore:count()

	destination = math.min(math.max(destination or self.state.chartview_set_index + direction, 1), itemsCount)
	if not self.chartSetStore:get(destination) or self.state.chartview_set_index == destination then
		return
	end

	local chartview_set = self.chartSetStore:get(destination)
	self:setConfig(chartview_set)

	self.state:setSet(destination, chartview_set.chartfile_set_id)
end

---@param direction number?
---@param destination number?
function SelectionManager:scrollNoteChart(direction, destination)
	local items = self.chartStore.items

	direction = direction or destination - self.state.chartview_index

	destination = math.min(math.max(destination or self.state.chartview_index + direction, 1), #items)
	if not items[destination] or self.state.chartview_index == destination then
		return
	end

	local chartview = items[destination]
	self:setConfig(chartview)

	self.chartview = chartview
	self.changed = true

	self.state:setChart(destination, chartview.chartfile_id)

	self.onChanged:send({type = "scroll_notechart", chartview = chartview})
end

---@param direction number?
---@param destination number?
function SelectionManager:scrollScore(direction, destination)
	local items = self.scoreStore.items

	destination = math.min(math.max(destination or self.state.scoreItemIndex + direction, 1), #items)
	if not items[destination] or self.state.scoreItemIndex == destination then
		return
	end

	local scoreItem = items[destination]
	self.config.chartplay_id = scoreItem.id

	self.state:setScore(destination, scoreItem.id)

	self.scoreItem = scoreItem
	self.onChanged:send({type = "scroll_score", scoreItem = scoreItem})
end

---@param noUpdate boolean?
---@param noPullNext boolean?
function SelectionManager:pullNoteChartSet(noUpdate, noPullNext)
	if self.locked then
		return
	end

	if not noUpdate then
		self:updateSetItems()
	end

	local index = self.chartSetStore:indexof(self.config)
	local chartview_set = self.chartSetStore:get(index)

	if chartview_set then
		self.config.chartfile_set_id = chartview_set.chartfile_set_id
		self.config.chartmeta_id = chartview_set.chartmeta_id  -- required by chartviews_table
	else
		self.config.chartfile_set_id = nil
		self.config.chartfile_id = nil
		self.config.chartmeta_id = nil
		self.config.chartdiff_id = nil
		self.config.chartplay_id = nil

		self.chartview = nil
		self.scoreItem = nil
		self.changed = true

		self.chartStore:clear()
		self.scoreStore:clear()
	end

	self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)

	if chartview_set then
		return
	end
end

---@param noUpdate boolean?
---@param noPullNext boolean?
function SelectionManager:pullNoteChart(noUpdate, noPullNext)
	if not noUpdate then
		self.chartStore:setNoteChartSetId(self.config)
	end

	local index = self.chartStore:indexof(self.config)
	local chartview = self.chartStore.items[index]

	if chartview then
		self.config.chartfile_id = chartview.chartfile_id
		self.config.chartmeta_id = chartview.chartmeta_id
		self.config.chartdiff_id = chartview.chartdiff_id
		self.config.chartplay_id = chartview.chartplay_id
	else
		self.config.chartfile_id = nil
		self.config.chartmeta_id = nil
		self.config.chartdiff_id = nil
		self.config.chartplay_id = nil
	end

	self.chartview = chartview
	self.changed = true

	self.state:setChart(index, chartview and chartview.chartfile_id)

	if chartview then
		return
	end

	self.scoreItem = nil
	self.scoreStore:clear()
end

function SelectionManager:findScore()
	local scoreItems = self.scoreStore.items
	local index = self.scoreStore:getItemIndex(self.config.chartplay_id) or 1
	local scoreItem = scoreItems[index]

	if scoreItem then
		self.config.chartplay_id = scoreItem.id
	end

	self.state:setScore(index, scoreItem and scoreItem.id)

	self.scoreItem = scoreItem
end

---@param noUpdate boolean?
function SelectionManager:pullScore(noUpdate)
	local items = self.chartStore.items
	local chartview = items[self.state.chartview_index]

	if not chartview then
		return
	end

	if noUpdate then
		self:findScore()
		return
	end

	local select = self.configModel.configs.select
	if select.scoreSourceName == "online" then
		self.scoreStore:clear()
		-- Handle debouncing within the serialized task runner
		if coroutine.running() then
			delay.sleep(self.debounceTime)
		end
	end

	local config = self.configModel.configs.settings.select
	local exact = config.chartviews_table ~= "chartviews"
	
	-- We use the coro version to ensure the task runner waits for completion
	self.scoreStore:updateItems(chartview, exact)

	self:findScore()
end

return SelectionManager
