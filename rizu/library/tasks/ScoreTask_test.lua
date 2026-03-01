local ScoreTask = require("rizu.library.tasks.ScoreTask")
local FakeTaskContext = require("rizu.library.tasks.FakeTaskContext")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local Database = require("rizu.library.Database")

local test = {}

local function setup_db()
	local db = Database()
	db:load(":memory:")
	return db
end

function test.computeAll(t)
	local db = setup_db()
	local chartsRepo = ChartsRepo(db.models)

	-- 1. Setup a chartplay that needs computation
	chartsRepo:createChartplay({
		user_id = 1,
		compute_state = "new",
		computed_at = 0,
		submitted_at = 0,
		replay_hash = "replay1",
		pause_count = 0,
		created_at = 0,
		hash = "hash1",
		index = 1,
		modifiers = {},
		rate = 1000,
		mode = "mania",
		nearest = false,
		tap_only = false,
		custom = false,
		const = false,
		rate_type = "linear",
		judges = {0,0,0,0,0,0},
		accuracy = 0,
		max_combo = 0,
		miss_count = 0,
		not_perfect_count = 0,
		pass = false,
		rating = 0,
		rating_pp = 0,
		rating_msd = 0
	})
	
	t:eq(chartsRepo:getChartplaysComputedCount(0, "new"), 1)

	local chartsComputer = {
		computeChartplay = function(_, chartplay)
			chartplay.compute_state = "valid"
			chartplay.computed_at = 0
			chartsRepo:updateChartplay(chartplay)
			return {chartplay_computed = {}}
		end
	}
	
	local context = FakeTaskContext()
	local task = ScoreTask(chartsRepo, chartsComputer, context)
	
	task:computeAll()
	
	-- Verify state updated in DB
	t:eq(chartsRepo:getChartplaysComputedCount(0, "new"), 0)
	local cp = chartsRepo:getChartplayByReplayHash("replay1")
	t:eq(cp.compute_state, "valid")

	db:unload()
end

return test
