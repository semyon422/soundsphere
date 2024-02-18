local class = require("class")
local path_util = require("path_util")

---@class sphere.NoteChartLibrary
---@operator call: sphere.NoteChartLibrary
local NoteChartLibrary = class()

NoteChartLibrary.set_id = 0
NoteChartLibrary.itemsCount = 0

---@param cacheModel sphere.CacheModel
function NoteChartLibrary:new(cacheModel)
	self.cacheModel = cacheModel
	self.items = {}
end

function NoteChartLibrary:clear()
	self.items = {}
end

---@param set_id number
function NoteChartLibrary:setNoteChartSetId(set_id)
	if set_id == self.set_id then
		return
	end
	self.set_id = set_id
	self.items = self.cacheModel.cacheDatabase:getChartviewsAtSet(set_id)
	if #self.items == 0 then
		return
	end
	local location = self.cacheModel.chartRepo:selectLocationById(self.items[1].location_id)
	local prefix = self.cacheModel.locationManager:getPrefix(location)
	for _, chart in ipairs(self.items) do
		chart.location_prefix = prefix
		chart.location_dir = path_util.join(prefix, chart.dir)
		chart.location_path = path_util.join(prefix, chart.path)
	end
end

---@param chartview table
---@return number
function NoteChartLibrary:indexof(chartview)
	local chartfile_id = chartview.chartfile_id
	local chartmeta_id = chartview.chartmeta_id
	local chartdiff_id = chartview.chartdiff_id

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
	return 1
end

return NoteChartLibrary
