local ComputeProcessor = require("sea.compute.ComputeProcessor")
local TableStorage = require("sea.chart.storage.TableStorage")
local ChartplayComputer = require("sea.compute.ChartplayComputer")
local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ChartfilesRepo = require("sea.chart.repos.ChartfilesRepo")
local ComputeProcessesRepo = require("sea.chart.repos.ComputeProcessesRepo")

local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local charts_repo = ChartsRepo(models)
	local chartfiles_repo = ChartfilesRepo(models)
	local compute_processes_repo = ComputeProcessesRepo(models)

	local charts_storage = TableStorage()
	local replays_storage = TableStorage()

	local compute_data_provider = ComputeDataProvider(chartfiles_repo, charts_storage, replays_storage)
	local chartplay_computer = ChartplayComputer()
	local compute_processor = ComputeProcessor(compute_data_provider, chartplay_computer, charts_repo, compute_processes_repo)

	return {
		db = db,
		charts_repo = charts_repo,
		chartfiles_repo = chartfiles_repo,
		compute_processes_repo = compute_processes_repo,
		charts_storage = charts_storage,
		replays_storage = replays_storage,
		compute_processor = compute_processor,
	}
end

---@param t testing.T
function test.chartplays_full(t)
	local ctx = create_test_ctx()

	local time = 10

	local compute_process = ctx.compute_processor:startChartplays(time, "valid")

	while not compute_process.completed_at do
		compute_process = ctx.compute_processor:step(compute_process)
	end
end

---@param t testing.T
function test.chartdiffs_full(t)
	local ctx = create_test_ctx()

	-- ctx.compute_processor:start
end

return test
