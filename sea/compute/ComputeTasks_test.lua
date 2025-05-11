local ComputeTasks = require("sea.compute.ComputeTasks")
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

	local compute_tasks = ComputeTasks(compute_tasks_repo)

	return {
		db = db,
		compute_tasks_repo = compute_tasks_repo,
		compute_tasks = compute_tasks,
	}
end

---@param t testing.T
function test.chartplays_valid(t)
	local ctx = create_test_ctx()

	local chartplays = {{}, {}}

	local compute_task = ctx.compute_tasks:createComputeTask(2, "chartplays", "valid", #chartplays)

	while not compute_task.completed_at do
		compute_task = ctx.compute_tasks:step(compute_task, #chartplays)
		chartplays = {}
	end

	t:eq(compute_task.current, compute_task.total)
	t:eq(compute_task.current, 2)
end

return test
