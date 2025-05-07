local ComputeProcessor = require("sea.compute.ComputeProcessor")
local ComputeProcessesRepo = require("sea.compute.repos.ComputeProcessesRepo")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())
	db.path = ":memory:"
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local compute_processes_repo = ComputeProcessesRepo(models)

	local charts_computer = {
		computeChartplay = function() return true end,
	}

	local compute_processor = ComputeProcessor(charts_computer, compute_processes_repo)

	return {
		db = db,
		compute_processes_repo = compute_processes_repo,
		compute_processor = compute_processor,
	}
end

---@param t testing.T
function test.chartplays_full_all_ok(t)
	local ctx = create_test_ctx()

	local chartplays = {{}, {}}

	local compute_process = ctx.compute_processor:startChartplays(2, "valid", #chartplays)

	while not compute_process.completed_at do
		compute_process = ctx.compute_processor:step(compute_process, chartplays)
		chartplays = {}
	end

	t:eq(compute_process.current, compute_process.total)
	t:eq(compute_process.current, 2)
end

return test
