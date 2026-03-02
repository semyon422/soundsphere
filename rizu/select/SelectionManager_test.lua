local SelectionManager = require("rizu.select.SelectionManager")
local SelectionState = require("rizu.select.SelectionState")
local TestLibraryFactory = require("rizu.select.TestLibraryFactory")
local class = require("class")

local test = {}

local tlf = TestLibraryFactory()

local function createMockConfigModel()
	return {
		configs = {
			settings = {
				select = {
					locations_in_collections = false,
					collapse = true,
					chartviews_table = "chartviews",
					diff_column = "msd_diff"
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

---@param t testing.T
function test.scrolling(t)
	local charts = {
		{chartfile_set_id = 1, chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 1, set_name = "Set 1", hash = "h1"},
		{chartfile_set_id = 2, chartfile_id = 2, chartmeta_id = 2, chartdiff_id = 2, set_name = "Set 2", hash = "h2"},
		{chartfile_set_id = 3, chartfile_id = 3, chartmeta_id = 3, chartdiff_id = 3, set_name = "Set 3", hash = "h3"}
	}
	local configModel = createMockConfigModel()
	local library = tlf:create()
	tlf:populate(library, charts)
	
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
		{chartfile_set_id = 1, chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 1, hash = "h1", index = 1},
		{chartfile_set_id = 1, chartfile_id = 2, chartmeta_id = 2, chartdiff_id = 2, hash = "h1", index = 2},
		{chartfile_set_id = 1, chartfile_id = 3, chartmeta_id = 3, chartdiff_id = 3, hash = "h1", index = 3}
	}
	local configModel = createMockConfigModel()
	local library = tlf:create()
	tlf:populate(library, charts)
	
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
	local configModel = createMockConfigModel()
	local library = tlf:create()
	tlf:populate(library, charts)
	
	-- Insert scores
	tlf:createScore(library, {id = 101, hash = "h1", index = 1, accuracy = 0.9, created_at = 1, rating = 300})
	tlf:createScore(library, {id = 102, hash = "h1", index = 1, accuracy = 0.95, created_at = 2, rating = 200})
	tlf:createScore(library, {id = 103, hash = "h1", index = 1, accuracy = 1.0, created_at = 3, rating = 100})

	local fs = {read = function() end, getInfo = function() end}
	local onlineModel = {authManager = {sea_client = {connected = false}}}
	local replayBase = {}

	local model = SelectionManager(configModel, library, fs, onlineModel, replayBase)
	model:load()

	-- Default selection should be the latest score (highest ID), which is 103
	t:eq(model.state.scoreItemIndex, 3)
	t:eq(model.state.scoreId, 103)

	model:scrollScore(-1)
	t:eq(model.state.scoreItemIndex, 2)
	t:eq(model.state.scoreId, 102)
	t:eq(model.scoreItem.id, 102)

	model:scrollScore(-1)
	t:eq(model.state.scoreItemIndex, 1)
	t:eq(model.state.scoreId, 101)
	t:eq(model.scoreItem.id, 101)

	-- Scroll forward
	model:scrollScore(1)
	t:eq(model.state.scoreItemIndex, 2)
	t:eq(model.state.scoreId, 102)
end

function test.task_overriding(t)
	local charts = {}
	for i = 1, 10 do
		table.insert(charts, {chartfile_set_id = i, chartfile_id = i, chartmeta_id = i, chartdiff_id = i, hash = "h" .. i})
	end
	
	local configModel = createMockConfigModel()
	local library = tlf:create()
	tlf:populate(library, charts)
	
	local fs = {read = function() end, getInfo = function() end}
	local onlineModel = {authManager = {sea_client = {connected = false}}}
	local replayBase = {}

	local model = SelectionManager(configModel, library, fs, onlineModel, replayBase)

	-- Mock chartStore to be "slow" by explicitly yielding
	local original_setNoteChartSetId = model.chartStore.setNoteChartSetId
	local calls = 0
	local yielded_threads = {}
	model.chartStore.setNoteChartSetId = function(self, config)
		calls = calls + 1
		table.insert(yielded_threads, coroutine.running())
		coroutine.yield()
		return original_setNoteChartSetId(self, config)
	end

	model:load()

	-- Fast scroll from 1 to 5
	model:scrollNoteChartSet(1) -- to 2
	model:scrollNoteChartSet(1) -- to 3
	model:scrollNoteChartSet(1) -- to 4
	model:scrollNoteChartSet(1) -- to 5

	-- Resume all yielded threads manually
	while #yielded_threads > 0 do
		local c = table.remove(yielded_threads, 1)
		assert(coroutine.resume(c))
	end

	t:eq(calls, 2, "Intermediate chart loads should have been overridden")
	t:eq(model.state.chartview_set_index, 5)
	t:eq(model.state.chartSetId, 5)
	t:eq(model.chartview.chartfile_id, 5)
end

return test
