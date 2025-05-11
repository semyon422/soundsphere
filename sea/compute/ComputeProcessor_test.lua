local ComputeProcessor = require("sea.compute.ComputeProcessor")
local ComputeTasksRepo = require("sea.compute.repos.ComputeTasksRepo")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())
	db.path = ":memory:"
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local compute_tasks_repo = ComputeTasksRepo(models)

	local charts_computer = {
		computeChartplay = function() return true end,
	}

	local compute_processor = ComputeProcessor(charts_computer, compute_tasks_repo)

	return {
		db = db,
		compute_tasks_repo = compute_tasks_repo,
		compute_processor = compute_processor,
	}
end

---@param t testing.T
function test.chartplays_full_all_ok(t)
	local ctx = create_test_ctx()

	local chartplays = {{}, {}}

	local compute_task = ctx.compute_processor:startChartplays(2, "valid", #chartplays)

	while not compute_task.completed_at do
		compute_task = ctx.compute_processor:step(compute_task, chartplays)
		chartplays = {}
	end

	t:eq(compute_task.current, compute_task.total)
	t:eq(compute_task.current, 2)
end

return test
