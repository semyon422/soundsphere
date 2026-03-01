local DifficultyTask = require("sphere.persistence.CacheModel.DifficultyTask")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local TestChartFactory = require("sea.chart.TestChartFactory")

local test = {}

local function setup_db()
	local gdb = GameDatabase()
	gdb:load(":memory:")
	return gdb
end

function test.computeMissing(t)
	local gdb = setup_db()
	local chartsRepo = ChartsRepo(gdb.models, {"enps_diff"})
	
	local tcf = TestChartFactory()
	local res = tcf:create("4key", {
		{time = 0, column = 1},
		{time = 1, column = 2}
	})

	local hash = "test_hash"
	res.chartmeta.hash = hash
	res.chartmeta.created_at = 0
	res.chartmeta.computed_at = 0
	chartsRepo:createChartmeta(res.chartmeta)
	
	-- Verify it shows up as missing
	local missing = chartsRepo:getChartmetasMissingChartdiffs()
	t:eq(#missing, 1)

	local difficultyModel = {
		compute = function(_, diff, chart, rate)
			diff.enps_diff = 10.0
		end
	}
	
	local chartdiffGenerator = {
		compute = function(_, chart, rate)
			local d = res.chartdiff
			d.rate = rate
			difficultyModel:compute(d, chart, rate)
			return d
		end
	}
	
	local context = FakeTaskContext()
	context.charts[hash] = {res.chart}
	
	local task = DifficultyTask(difficultyModel, chartdiffGenerator, chartsRepo, context)
	
	task:computeMissing()
	
	-- Verify diff was created
	local diff = chartsRepo:selectDefaultChartdiff(hash, 1)
	t:assert(diff)
	t:eq(diff.enps_diff, 10.0)
	
	-- Verify missing is now empty
	missing = chartsRepo:getChartmetasMissingChartdiffs()
	t:eq(#missing, 0)

	gdb:unload()
end

return test
