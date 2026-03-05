local Database = require("rizu.library.Database")
local LoveFilesystem = require("fs.LoveFilesystem")
local ChartviewsRepo = require("rizu.library.repos.ChartviewsRepo")
local TestChartFactory = require("sea.chart.TestChartFactory")

local test = {}

local function setup()
	local db = Database(LoveFilesystem())
	db:load(":memory:")

	local factory = TestChartFactory()

	-- Insert test data using models
	db.models.locations:create({
		id = 1,
		name = "Test",
		path = "/test",
		is_relative = 0,
		is_internal = 0,
	})

	db.models.chartfile_sets:create({
		id = 1,
		location_id = 1,
		name = "Set",
		dir = "set",
		modified_at = 0,
		is_file = 0,
	})

	db.models.chartfiles:create({
		id = 1,
		set_id = 1,
		name = "chart.osu",
		hash = "hash1",
		modified_at = 0,
	})

	-- Create and insert chartmeta
	local chartmeta = factory:createChartmeta({
		id = 1,
		hash = "hash1",
		index = 0,
		inputmode = "4key",
		format = "sphere",
	})
	db.models.chartmetas:create(chartmeta)

	-- Two diffs: one standard (1.0x), one custom (1.1x)
	local diff1 = factory:createChartdiff({
		id = 1,
		hash = "hash1",
		index = 0,
		rate = 1.0,
		enps_diff = 1.0,
		inputmode = "4key",
	})
	db.models.chartdiffs:create(diff1)

	local diff2 = factory:createChartdiff({
		id = 2,
		hash = "hash1",
		index = 0,
		rate = 1.1,
		enps_diff = 1.1,
		inputmode = "4key",
	})
	db.models.chartdiffs:create(diff2)

	-- Three plays: two for rate 1.0, one for rate 1.1
	db.models.chartplays:create(factory:createChartplay({
		id = 1, hash = "hash1", index = 0, rate = 1.0, accuracy = 0.95, created_at = 100,
	}))
	db.models.chartplays:create(factory:createChartplay({
		id = 2, hash = "hash1", index = 0, rate = 1.1, accuracy = 0.96, created_at = 200,
	}))
	db.models.chartplays:create(factory:createChartplay({
		id = 3, hash = "hash1", index = 0, rate = 1.0, accuracy = 0.97, created_at = 300,
	}))

	-- Insert difftable_chartmeta for rich data testing
	db.models.difftables:create({
		id = 1, name = "Test Table", description = "desc", symbol = "T", created_at = 0,
	})
	db.models.difftable_chartmetas:create({
		id = 1, user_id = 1, difftable_id = 1, hash = "hash1", index = 0, level = 10.0,
		is_deleted = 0, change_index = 1, created_at = 0, updated_at = 0,
	})

	local repo = ChartviewsRepo(db.models)
	repo:setSync(true)
	repo.params = {
		difficulty = "enps_diff",
		where = {},
	}

	return db, repo, factory
end

---@param t testing.T
function test.chartviews_mode(t)
	local db, repo = setup()
	repo.params.chartviews_table = "chartviews"
	repo:queryAsync(repo.params)

	t:eq(repo.chartviews_count, 1, "Should group by chartmeta")

	local views = repo:getChartviewsAtSet({chartfile_set_id = 1})
	t:eq(#views, 1)
	t:eq(views[1].rate, 1, "Should return standard diff")
	
	db:unload()
end

---@param t testing.T
function test.chartdiffviews_mode(t)
	local db, repo = setup()
	repo.params.chartviews_table = "chartdiffviews"
	repo:queryAsync(repo.params)

	t:eq(repo.chartviews_count, 2, "Should have one entry per diff")

	local views = repo:getChartviewsAtSet({chartfile_set_id = 1, chartmeta_id = 1})
	t:eq(#views, 2)
	t:eq(views[1].rate, 1)
	t:eq(views[2].rate, 1.1)
	
	db:unload()
end

---@param t testing.T
function test.chartplayviews_mode(t)
	local db, repo = setup()
	repo.params.chartviews_table = "chartplayviews"
	repo:queryAsync(repo.params)

	t:eq(repo.chartviews_count, 3, "Should have one entry per play")

	local views = repo:getChartviewsAtSet({chartfile_set_id = 1, chartmeta_id = 1})
	t:eq(#views, 3)
	t:eq(views[1].chartplay_id, 1)
	t:eq(views[2].chartplay_id, 2)
	t:eq(views[3].chartplay_id, 3)
	
	db:unload()
end

---@param t testing.T
function test.rich_data_enrichment(t)
	local db, repo = setup()
	repo.params.chartviews_table = "chartviews"
	
	local views = repo:getChartviewsAtSet({chartfile_set_id = 1})
	t:assert(views[1].difftable_chartmetas, "Should load difftable_chartmetas in list")
	t:eq(#views[1].difftable_chartmetas, 1)

	local cv = repo:getChartview({chartfile_id = 1})
	t:assert(cv.difftable_chartmetas, "Should load difftable_chartmetas in getChartview")
	
	db:unload()
end

---@param t testing.T
function test.getChartview_fallbacks(t)
	local db, repo = setup()
	repo.params.chartviews_table = "chartplayviews"

	-- Happy path
	local cpv = repo:getChartview({chartfile_id = 1, chartplay_id = 3})
	t:eq(cpv.chartplay_id, 3)

	-- Fallback to diff_id
	local fallback1 = repo:getChartview({chartfile_id = 1, chartdiff_id = 2, chartplay_id = 999})
	t:eq(fallback1.chartdiff_id, 2)
	t:eq(fallback1.chartplay_id, 2)

	-- Fallback to meta_id
	local fallback2 = repo:getChartview({chartfile_id = 1, chartmeta_id = 1, chartdiff_id = 999})
	t:eq(fallback2.chartmeta_id, 1)

	-- Fallback to file_id
	local fallback3 = repo:getChartview({chartfile_id = 1})
	t:eq(fallback3.chartfile_id, 1)

	-- No match
	t:eq(repo:getChartview({chartfile_id = 999}), nil)

	db:unload()
end

return test
