local SelectionManager = require("rizu.select.SelectionManager")
local SelectionState = require("rizu.select.SelectionState")
local class = require("class")

local test = {}

local function createMockConfigModel()
	return {
		configs = {
			settings = {
				select = {
					locations_in_collections = false,
					collapse = true,
					chartviews_table = "chartviews",
					diff_column = "difficulty"
				},
				gameplay = {
					ratingHitTimingWindow = 0.05
				},
				miscellaneous = {
					showNonManiaCharts = true
				}
			},
			select = {
				searchMode = "title",
				collection = "",
				location_id = 0,
				sortFunction = "title",
				selected_filters = {},
				filterString = "",
				lampString = "",
				scoreSourceName = "local",
				scoreFilterName = "all"
			},
			filters = {
				notechart = {},
				score = {{name = "all"}}
			}
		}
	}
end

local function createMockLibrary(charts)
	local lib = {
		chartviewsRepo = {
			chartviews = {},
			chartviews_count = charts and #charts or 0,
			queryAsync = function(self, params) end,
			getChartview = function(self, v) return v end,
			getChartviewsAtSet = function(self, chartview)
				local items = {}
				for i = 0, self.chartviews_count - 1 do
					local c = self.chartviews[i]
					if c.chartfile_set_id == chartview.chartfile_set_id then
						table.insert(items, c)
					end
				end
				return items
			end,
			chartplay_id_to_global_index = {},
			chartdiff_id_to_global_index = {},
			chartfile_id_to_global_index = {},
			set_id_to_global_index = {},
		},
		difftablesRepo = {
			getDifftableChartmetasForChartmeta = function() return {} end
		},
		collectionLibrary = {},
		getCollectionTree = function() 
			return {items = {}, indexes = {}, selected = 1} 
		end,
		locationsRepo = {
			selectLocationById = function() return {path = ""} end
		},
		locations = {
			getPrefix = function() return "" end
		},
		chartsRepo = {
			getChartplaysForChartplay = function() return {} end,
			getChartplaysForChartmeta = function() return {} end,
			getChartplaysForChartdiff = function() return {} end
		},
		getCollectionTree = function() return {items = {}, indexes = {}, selected = 1} end,
	}
	if charts then
		for i, c in ipairs(charts) do
			lib.chartviewsRepo.chartviews[i - 1] = c
			if c.chartplay_id then lib.chartviewsRepo.chartplay_id_to_global_index[c.chartplay_id] = i end
			if c.chartdiff_id then lib.chartviewsRepo.chartdiff_id_to_global_index[c.chartdiff_id] = i end
			if c.chartfile_id then lib.chartviewsRepo.chartfile_id_to_global_index[c.chartfile_id] = i end
			if c.chartfile_set_id then lib.chartviewsRepo.set_id_to_global_index[c.chartfile_set_id] = i end
		end
	end
	return lib
end

---@param t testing.T
function test.scrolling(t)
	local charts = {
		{chartfile_set_id = 1, chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 1},
		{chartfile_set_id = 2, chartfile_id = 2, chartmeta_id = 2, chartdiff_id = 2},
		{chartfile_set_id = 3, chartfile_id = 3, chartmeta_id = 3, chartdiff_id = 3}
	}
	local configModel = createMockConfigModel()
	local library = createMockLibrary(charts)
	local fs = {read = function() end, getInfo = function() end}
	local onlineModel = {authManager = {sea_client = {connected = false}}}
	local replayBase = {}

	local model = SelectionManager(configModel, library, fs, onlineModel, replayBase)
	model:load()

	t:eq(model.state.chartview_set_index, 1)
	t:eq(model.state.chartSetId, 1)

	model:scrollNoteChartSet(1)
	t:eq(model.state.chartview_set_index, 2)
	t:eq(model.state.chartSetId, 2)
	t:eq(model.chartview.chartfile_id, 2)

	model:scrollNoteChartSet(1)
	t:eq(model.state.chartview_set_index, 3)
	t:eq(model.state.chartSetId, 3)
	t:eq(model.chartview.chartfile_id, 3)

	-- Scroll back
	model:scrollNoteChartSet(-1)
	t:eq(model.state.chartview_set_index, 2)
	t:eq(model.state.chartSetId, 2)
end

function test.chart_navigation(t)
	local charts = {
		{chartfile_set_id = 1, chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 1},
		{chartfile_set_id = 1, chartfile_id = 2, chartmeta_id = 1, chartdiff_id = 2},
		{chartfile_set_id = 1, chartfile_id = 3, chartmeta_id = 1, chartdiff_id = 3}
	}
	local configModel = createMockConfigModel()
	local library = createMockLibrary(charts)
	local fs = {read = function() end, getInfo = function() end}
	local onlineModel = {authManager = {sea_client = {connected = false}}}
	local replayBase = {}

	local model = SelectionManager(configModel, library, fs, onlineModel, replayBase)
	model:load()

	t:eq(model.state.chartview_index, 1)
	t:eq(model.state.chartId, 1)

	model:scrollNoteChart(1)
	t:eq(model.state.chartview_index, 2)
	t:eq(model.state.chartId, 2)
	t:eq(model.chartview.chartfile_id, 2)

	model:scrollNoteChart(1)
	t:eq(model.state.chartview_index, 3)
	t:eq(model.state.chartId, 3)
	t:eq(model.chartview.chartfile_id, 3)

	-- Scroll back
	model:scrollNoteChart(-1)
	t:eq(model.state.chartview_index, 2)
	t:eq(model.state.chartId, 2)
end

function test.score_navigation(t)
	local charts = {
		{chartfile_set_id = 1, chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 1, hash = "h1", index = 1}
	}
	local scores = {
		{id = 101, accuracy = 0.9},
		{id = 102, accuracy = 0.95},
		{id = 103, accuracy = 1.0}
	}
	local configModel = createMockConfigModel()
	local library = createMockLibrary(charts)
	library.chartsRepo.getChartplaysForChartmeta = function() return scores end
	library.chartsRepo.getChartplaysForChartdiff = function() return scores end
	
	local fs = {read = function() end, getInfo = function() end}
	local onlineModel = {authManager = {sea_client = {connected = false}}}
	local replayBase = {}

	local model = SelectionManager(configModel, library, fs, onlineModel, replayBase)
	model:load()

	t:eq(model.state.scoreItemIndex, 1)
	t:eq(model.state.scoreId, 101)

	model:scrollScore(1)
	t:eq(model.state.scoreItemIndex, 2)
	t:eq(model.state.scoreId, 102)
	t:eq(model.scoreItem.id, 102)

	model:scrollScore(1)
	t:eq(model.state.scoreItemIndex, 3)
	t:eq(model.state.scoreId, 103)
	t:eq(model.scoreItem.id, 103)

	-- Scroll back
	model:scrollScore(-1)
	t:eq(model.state.scoreItemIndex, 2)
	t:eq(model.state.scoreId, 102)
end

return test
