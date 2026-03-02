local class = require("class")
local delay = require("delay")
local thread = require("thread")
local path_util = require("path_util")
local table_util = require("table_util")
local Observable = require("aqua.Observable")
local ChartFactory = require("notechart.ChartFactory")
local SelectionState = require("rizu.select.SelectionState")
local NoteChartLibrary = require("sphere.models.SelectModel.NoteChartLibrary")
local NoteChartSetLibrary = require("sphere.models.SelectModel.NoteChartSetLibrary")
local CollectionLibrary = require("sphere.models.SelectModel.CollectionLibrary")
local ScoreLibrary = require("sphere.models.SelectModel.ScoreLibrary")
local SearchModel = require("sphere.models.SelectModel.SearchModel")
local SortModel = require("sphere.models.SelectModel.SortModel")
local FilterModel = require("sphere.models.SelectModel.FilterModel")
local LocalScoreProvider = require("sphere.models.SelectModel.LocalScoreProvider")
local OnlineScoreProvider = require("sphere.models.SelectModel.OnlineScoreProvider")

---@class sphere.SelectModel
---@operator call: sphere.SelectModel
local SelectModel = class()

SelectModel.pullingNoteChartSet = false
SelectModel.debounceTime = 0.5

---@param configModel sphere.ConfigModel
---@param library rizu.library.Library
---@param fs fs.IFilesystem
---@param onlineModel sphere.OnlineModel
---@param replayBase sea.ReplayBase
---@param state? rizu.select.SelectionState
function SelectModel:new(configModel, library, fs, onlineModel, replayBase, state)
	self.configModel = configModel
	self.library = library
	self.fs = fs
	self.onlineModel = onlineModel
	self.replayBase = replayBase
	self.state = state or SelectionState()

	self.noteChartLibrary = NoteChartLibrary(library)
	self.noteChartSetLibrary = NoteChartSetLibrary(library)
	self.collectionLibrary = CollectionLibrary(library)
	self.searchModel = SearchModel(configModel)
	self.filterModel = FilterModel(configModel)
	self.sortModel = SortModel()

	local localProvider = LocalScoreProvider(library)
	local onlineProvider = OnlineScoreProvider(onlineModel)
	self.scoreLibrary = ScoreLibrary(
		configModel,
		localProvider,
		onlineProvider
	)
	self.onChanged = Observable()
	self.state.onChanged:add(self)
end

---@param event table
function SelectModel:receive(event)
	if event.type == "set" then
		self:pullNoteChart()
	elseif event.type == "chart" then
		self:pullScore()
		local index = self.noteChartSetLibrary:indexof(self.config)
		local chartview_set = self.noteChartSetLibrary:get(index)
		self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)
	end
end

function SelectModel:load()
	local settings = self.configModel.configs.settings
	local config = self.configModel.configs.select
	self.config = config

	self.searchMode = config.searchMode

	self.noteChartSetStateCounter = 1
	self.noteChartStateCounter = 1
	self.scoreStateCounter = 1

	self.collectionLibrary:load(settings.select.locations_in_collections)
	self.collectionLibrary:setPath(config.collection, config.location_id)

	self.filterModel:apply()

	self:noDebouncePullNoteChartSet()
end

function SelectModel:updateSetItems()
	local config = self.configModel.configs.settings.select

	local params = {}

	local order, group_allowed = self.sortModel:getOrder(self.config.sortFunction)

	params.order = table_util.copy(order)
	table.insert(params.order, "chartmeta_id")

	local group = group_allowed and config.collapse and config.chartviews_table == "chartviews"
	if group then
		params.group = {"chartfile_set_id"}
	end

	local where, lamp = self.searchModel:getConditions()
	table_util.append(where, self.filterModel.combined_filters)

	local collectionLibrary = self.collectionLibrary
	local collectionItem = collectionLibrary.tree.items[collectionLibrary.tree.selected]

	if collectionItem then
		local path = collectionItem.path
		if path then
			where.set_dir__startswith = path
		end
		where.location_id = collectionItem.location_id
	end

	params.where = where
	params.lamp = lamp
	params.difficulty = config.diff_column
	params.chartviews_table = config.chartviews_table

	self.library.chartviewsRepo:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
	self.onChanged:send({type = "update_set_items"})
end

---@param hash string
---@param index number
function SelectModel:findNotechart(hash, index)
	local config = self.configModel.configs.settings.select
	local params = {
		where = {hash = hash, index = index},
		difficulty = config.diff_column,
	}
	self.library.chartviewsRepo:queryAsync(params)
	self.noteChartSetLibrary:updateItems()
	local chartview_set = self.noteChartSetLibrary:get(1)
	if chartview_set then
		self.noteChartLibrary:setNoteChartSetId(chartview_set)
	end
	self.onChanged:send({type = "find_notechart", hash = hash, index = index})
end

---@return string?
function SelectModel:getBackgroundPath()
	local chartview = self.chartview
	if not chartview then
		return
	end

	local name = chartview.chartfile_name
	if name:find("%.ojn$") or name:find("%.mid$") then
		return chartview.location_path
	end

	local background_path = chartview.background_path
	if not background_path or background_path == "" then
		return chartview.location_dir
	end

	return path_util.join(chartview.location_dir, background_path)
end

---@return string?
---@return number?
---@return string?
function SelectModel:getAudioPathPreview()
	local chartview = self.chartview
	if not chartview then
		return
	end

	local mode = "absolute"

	local audio_path = chartview.audio_path
	if not audio_path or audio_path == "" then
		return "", 0.4, "relative"
	end

	local full_path = path_util.join(chartview.real_dir, audio_path)
	local preview_time = chartview.preview_time

	local format = chartview.format
	if preview_time < 0 and (format == "osu" or format == "qua") then
		mode = "relative"
		preview_time = 0.4
	end

	return full_path, preview_time, mode
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function SelectModel:loadChart(settings)
	local chartview = self.chartview

	local content = self.fs:read(chartview.location_path)
	if not content then
		return
	end

	local chart_chartmetas = assert(ChartFactory:getCharts(
		chartview.chartfile_name,
		content
	))
	local t = chart_chartmetas[chartview.index]

	return t.chart, t.chartmeta
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function SelectModel:loadChartAbsolute(settings)
	local chart, chartmeta = self:loadChart(settings)
	if not chart then
		return
	end
	chart.layers.main:toAbsolute()
	return chart, chartmeta
end

---@return boolean
function SelectModel:isChanged()
	local changed = self.changed
	self.changed = false
	return changed == true
end

function SelectModel:setChanged()
	self.changed = true
	self.onChanged:send({type = "set_changed"})
end

---@return boolean
function SelectModel:notechartExists()
	local chartview = self.chartview
	if chartview then
		return self.fs:getInfo(chartview.location_path) ~= nil
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
	if self.chartview then
		self:setConfig(self.chartview)
	end
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
---@param force boolean?
function SelectModel:scrollCollection(direction, destination, force)
	if self.pullingNoteChartSet then
		return
	end

	local collectionLibrary = self.collectionLibrary
	local items = collectionLibrary.tree.items
	local selected = collectionLibrary.tree.selected

	destination = math.min(math.max(destination or selected + direction, 1), #items)
	if not items[destination] or not force and selected == destination then
		return
	end

	local old_item = items[collectionLibrary.tree.selected]

	collectionLibrary.tree.selected = destination

	local item = items[destination]
	self.config.collection = item.path
	self.config.location_id = item.location_id

	self:debouncePullNoteChartSet(old_item and old_item.path == item.path)
end

function SelectModel:scrollRandom()
	local itemsCount = self.noteChartSetLibrary:count()
	local destination = math.random(1, itemsCount)
	self:scrollNoteChartSet(nil, destination)
end

---@param chartview table
function SelectModel:setConfig(chartview)
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
function SelectModel:scrollNoteChartSet(direction, destination)
	local itemsCount = self.noteChartSetLibrary:count()

	destination = math.min(math.max(destination or self.state.chartview_set_index + direction, 1), itemsCount)
	if not self.noteChartSetLibrary:get(destination) or self.state.chartview_set_index == destination then
		return
	end

	local old_chartview_set = self.noteChartSetLibrary:get(self.state.chartview_set_index)
	local chartview_set = self.noteChartSetLibrary:get(destination)
	self:setConfig(chartview_set)

	self.state:setSet(destination, chartview_set.chartfile_set_id)
end

---@param direction number?
---@param destination number?
function SelectModel:scrollNoteChart(direction, destination)
	local items = self.noteChartLibrary.items

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
function SelectModel:scrollScore(direction, destination)
	local items = self.scoreLibrary.items

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
function SelectModel:pullNoteChartSet(noUpdate, noPullNext)
	if self.locked then
		return
	end

	self.pullingNoteChartSet = true

	if not noUpdate then
		self:updateSetItems()
	end

	local index = self.noteChartSetLibrary:indexof(self.config)
	local chartview_set = self.noteChartSetLibrary:get(index)

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

		self.noteChartLibrary:clear()
		self.scoreLibrary:clear()
	end

	self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)

	if not noUpdate then
		self.noteChartSetStateCounter = self.noteChartSetStateCounter + 1
	end

	if chartview_set then
		self.pullingNoteChartSet = false
		return
	end

	self.pullingNoteChartSet = false
end

---@param noUpdate boolean?
---@param noPullNext boolean?
function SelectModel:pullNoteChart(noUpdate, noPullNext)
	local old_chartview = self.chartview

	if not noUpdate then
		self.noteChartLibrary:setNoteChartSetId(self.config)
	end

	local index = self.noteChartLibrary:indexof(self.config)
	local chartview = self.noteChartLibrary.items[index]

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

	if not noUpdate then
		self.noteChartStateCounter = self.noteChartStateCounter + 1
	end

	if chartview then
		return
	end

	self.scoreItem = nil
	self.scoreLibrary:clear()
end

function SelectModel:findScore()
	local scoreItems = self.scoreLibrary.items
	local index = self.scoreLibrary:getItemIndex(self.config.chartplay_id) or 1
	local scoreItem = scoreItems[index]

	if scoreItem then
		self.config.chartplay_id = scoreItem.id
	end

	self.state:setScore(index, scoreItem and scoreItem.id)

	self.scoreItem = scoreItem
end

function SelectModel:updateScoresAsync()
	local chartview = self.chartview
	if not chartview then
		return
	end

	local config = self.configModel.configs.settings.select
	local exact = config.chartviews_table ~= "chartviews"
	self.scoreLibrary:updateItemsAsync(chartview, exact)
	self:findScore()
end

---@param noUpdate boolean?
function SelectModel:pullScore(noUpdate)
	local items = self.noteChartLibrary.items
	local chartview = items[self.state.chartview_index]

	if not chartview then
		return
	end

	if noUpdate then
		self:findScore()
		return
	end

	self.scoreStateCounter = self.scoreStateCounter + 1

	local select = self.configModel.configs.select
	if select.scoreSourceName == "online" then
		self.scoreLibrary:clear()
		delay.debounce(self, "scoreDebounce", self.debounceTime,
			self.updateScoresAsync, self
		)
		return
	end

	local config = self.configModel.configs.settings.select
	local exact = config.chartviews_table ~= "chartviews"
	self.scoreLibrary:updateItems(chartview, exact)

	self:findScore()
end

return SelectModel
