local class = require("class")
local delay = require("delay")
local Observable = require("Observable")
local SelectionState = require("rizu.select.SelectionState")
local ChartStore = require("rizu.select.stores.ChartStore")
local ChartSetStore = require("rizu.select.stores.ChartSetStore")
local SearchModel = require("rizu.select.SearchModel")
local SortModel = require("rizu.select.SortModel")
local FilterModel = require("rizu.select.FilterModel")
local SelectionQueryBuilder = require("rizu.select.SelectionQueryBuilder")
local ChartMetadataService = require("rizu.select.services.ChartMetadataService")
local TaskRunner = require("rizu.select.tasks.TaskRunner")

---@class rizu.select.ChartSelector
---@operator call: rizu.select.ChartSelector
local ChartSelector = class()

ChartSelector.debounceTime = 0.5

---@param configModel sphere.ConfigModel
---@param library rizu.library.Library
---@param fs fs.IFilesystem
---@param collectionSelector rizu.select.CollectionSelector
---@param state? rizu.select.SelectionState
function ChartSelector:new(configModel, library, fs, collectionSelector, state)
	self.configModel = configModel
	self.library = library
	self.fs = fs
	self.collectionSelector = collectionSelector
	self.state = state or SelectionState()

	self.chartStore = ChartStore(library)
	self.chartSetStore = ChartSetStore(library)
	self.searchModel = SearchModel(configModel)
	self.filterModel = FilterModel(configModel)
	self.sortModel = SortModel()
	self.queryBuilder = SelectionQueryBuilder(configModel, self.sortModel, self.searchModel, self.filterModel)
	self.metadataService = ChartMetadataService(fs)
	self.taskRunner = TaskRunner()

	self.onChanged = Observable()
	self.state.onChanged:add(self)
end

function ChartSelector:receive(event)
	if event.type == "set" then
		self.taskRunner:push(function()
			self:pullNoteChart()
		end, 1)
	elseif event.type == "chart" then
		self.taskRunner:push(function()
			local index = self.chartSetStore:indexof(self.config)
			local chartview_set = self.chartSetStore:get(index)
			self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)
		end, 2)
	end
end

function ChartSelector:load()
	local config = self.configModel.configs.select
	self.config = config

	self.searchMode = config.searchMode

	self.filterModel:apply()

	self:noDebouncePullNoteChartSet()
end

function ChartSelector:updateSetItems()
	local collectionItem = self.collectionSelector:getSelectedItem()
	local params = self.queryBuilder:build(self.config, collectionItem)

	self.library.chartviewsRepo:queryAsync(params)
	self.chartSetStore:updateItems()
	self.onChanged:send({type = "update_set_items"})
end

---@param hash string
---@param index number
function ChartSelector:findNotechart(hash, index)
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
function ChartSelector:getBackgroundPath()
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:getBackgroundPath(chartview)
end

---@return string?
---@return number?
---@return string?
function ChartSelector:getAudioPathPreview()
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:getAudioPathPreview(chartview)
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function ChartSelector:loadChart(settings)
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:loadChart(chartview)
end

---@param settings table?
---@return ncdk2.Chart?
---@return sea.Chartmeta?
function ChartSelector:loadChartAbsolute(settings)
	local chartview = self.chartview
	if not chartview then
		return
	end
	return self.metadataService:loadChartAbsolute(chartview)
end

---@return boolean
function ChartSelector:isChanged()
	local changed = self.changed
	self.changed = false
	return changed == true
end

function ChartSelector:setChanged()
	self.changed = true
	self.onChanged:send({type = "set_changed"})
end

---@return boolean
function ChartSelector:notechartExists()
	local chartview = self.chartview
	if chartview then
		return self.fs:getInfo(chartview.location_path) ~= nil
	end
	return false
end

---@param ... any?
function ChartSelector:debouncePullNoteChartSet(...)
	delay.debounce(self, "pullNoteChartSetDebounce", self.debounceTime, self.pullNoteChartSet, self, ...)
end

function ChartSelector:noDebouncePullNoteChartSet(...)
	local args = {...}
	self.taskRunner:push(function()
		self:pullNoteChartSet(unpack(args))
		if self.chartview then
			self:setConfig(self.chartview)
		end
	end, 1)
end

---@param sortFunctionName string
function ChartSelector:setSortFunction(sortFunctionName)
	self.config.sortFunction = sortFunctionName
	self:noDebouncePullNoteChartSet()
end

---@param locked boolean
function ChartSelector:setLock(locked)
	self.locked = locked
end

function ChartSelector:scrollRandom()
	local itemsCount = self.chartSetStore:count()
	local destination = math.random(1, itemsCount)
	self:scrollNoteChartSet(nil, destination)
end

---@param chartview table
function ChartSelector:setConfig(chartview)
	self.config.chartfile_set_id = chartview.chartfile_set_id
	self.config.chartfile_id = chartview.chartfile_id
	self.config.chartmeta_id = chartview.chartmeta_id
	self.config.chartdiff_id = chartview.chartdiff_id
	self.config.chartplay_id = chartview.chartplay_id
	self.config.select_chartplay_id = chartview.chartplay_id
end

---@param direction number?
---@param destination number?
function ChartSelector:scrollNoteChartSet(direction, destination)
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
function ChartSelector:scrollNoteChart(direction, destination)
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

---@param noUpdate boolean?
---@param noPullNext boolean?
function ChartSelector:pullNoteChartSet(noUpdate, noPullNext)
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
		self.config.chartmeta_id = chartview_set.chartmeta_id  -- required for chart and diff levels
	else
		self.config.chartfile_set_id = nil
		self.config.chartfile_id = nil
		self.config.chartmeta_id = nil
		self.config.chartdiff_id = nil
		self.config.chartplay_id = nil

		self.chartview = nil
		self.changed = true

		self.chartStore:clear()
	end

	self.state:setSet(index, chartview_set and chartview_set.chartfile_set_id)

	if chartview_set and not noPullNext then
		self:pullNoteChart()
	end
end

---@param noUpdate boolean?
---@param noPullNext boolean?
function ChartSelector:pullNoteChart(noUpdate, noPullNext)
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
end

return ChartSelector
