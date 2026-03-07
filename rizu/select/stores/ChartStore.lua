local class = require("class")
local path_util = require("path_util")
local Observable = require("Observable")

---@class rizu.select.stores.ChartStore
---@operator call: rizu.select.stores.ChartStore
local ChartStore = class()

ChartStore.itemsCount = 0

---@param library rizu.library.Library
function ChartStore:new(library)
	self.library = library
	---@type rizu.library.LocatedChartview[]
	self.items = {}
	self.set_id = nil
	self.chartfile_id = nil
	self.chartmeta_id = nil
	self.chartdiff_id = nil
	self.chartplay_id = nil
	self.onChanged = Observable()
end

function ChartStore:__index(k)
	if type(k) == "number" then
		return self.items[k]
	end
	return ChartStore[k]
end

function ChartStore:clear()
	self.items = {}
	self.set_id = nil
	self.chartfile_id = nil
	self.chartmeta_id = nil
	self.chartdiff_id = nil
	self.chartplay_id = nil
	self.onChanged:send({items = self.items})
end

---@return number
function ChartStore:count()
	return #self.items
end

---@param chartview rizu.library.IChartviewBase
function ChartStore:setNoteChartSetId(chartview)
	if self.set_id == chartview.chartfile_set_id and
	   self.chartfile_id == chartview.chartfile_id and
	   self.chartmeta_id == chartview.chartmeta_id and
	   self.chartdiff_id == chartview.chartdiff_id and
	   self.chartplay_id == chartview.chartplay_id then
		-- return
	end
	self.set_id = chartview.chartfile_set_id
	self.chartfile_id = chartview.chartfile_id
	self.chartmeta_id = chartview.chartmeta_id
	self.chartdiff_id = chartview.chartdiff_id
	self.chartplay_id = chartview.chartplay_id

	---@type rizu.library.LocatedChartview[]
	self.items = self.library.chartviewsRepo:getSecondaryViews(chartview)
	if #self.items == 0 then
		self.onChanged:send({items = self.items})
		return
	end
	local location = self.library.locationsRepo:selectLocationById(self.items[1].location_id)
	local prefix = self.library.locations:getPrefix(location)
	for _, chart in ipairs(self.items) do
		chart.location_prefix = prefix
		chart.location_dir = path_util.join(prefix, chart.dir)
		chart.location_path = path_util.join(prefix, chart.path)
		chart.real_dir = path_util.join(location.path, chart.dir)
		chart.real_path = path_util.join(location.path, chart.path)
	end
	self.onChanged:send({items = self.items})
end

---@param chartview rizu.library.IChartviewBase
---@return number
function ChartStore:indexof(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartmeta_id = chartview.chartmeta_id
	local chartdiff_id = chartview.chartdiff_id
	local chartplay_id = chartview.chartplay_id

	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartdiff_id == chartdiff_id and chart.chartplay_id == chartplay_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartdiff_id == chartdiff_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartfile_id == chartfile_id and chart.chartmeta_id == chartmeta_id then
			return i
		end
	end
	for i, chart in ipairs(self.items) do
		if chart.chartdiff_id == chartdiff_id then
			return i
		end
	end
	return 1
end

return ChartStore
