local TableStorage = require("sea.chart.storage.TableStorage")
local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local FakeClient = require("sea.compute.FakeClient")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ChartfilesRepo = require("sea.chart.repos.ChartfilesRepo")
local ChartsComputer = require("sea.compute.ChartsComputer")
local Chartplays = require("sea.chart.Chartplays")
local User = require("sea.access.User")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local chart_samples = require("sea.chart.samples")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())
	db.path = ":memory:"
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local charts_repo = ChartsRepo(models)
	local chartfiles_repo = ChartfilesRepo(models)

	local charts_storage = TableStorage()
	local replays_storage = TableStorage()

	local compute_data_provider = ComputeDataProvider(chartfiles_repo, charts_storage, replays_storage)
	local compute_data_loader = ComputeDataLoader(compute_data_provider)
	local charts_computer = ChartsComputer(compute_data_loader, charts_repo)

	local chartplays = Chartplays(
		charts_repo,
		chartfiles_repo,
		compute_data_loader,
		charts_storage,
		replays_storage
	)

	local user = User()
	user.id = 1

	return {
		db = db,
		charts_repo = charts_repo,
		chartfiles_repo = chartfiles_repo,
		charts_storage = charts_storage,
		replays_storage = replays_storage,
		chartplays = chartplays,
		charts_computer = charts_computer,
		user = user,
	}
end

---@param t testing.T
function test.chartplays_full(t)
	local ctx = create_test_ctx()
	local sample = chart_samples[1]

	local client = FakeClient(0.02, 100)

	local count = 4
	for i = 1, count do
		local time = i * ctx.chartplays.chartplays_access.submit_interval
		local play = client:play(sample.name, sample.data, 1, time, 0)
		local c, err = ctx.chartplays:submit(ctx.user, time, client.compute_data_loader, play.chartplay, play.chartdiff)
		t:assert(c, err)
	end

	local chartplays = ctx.chartplays:getChartplays()
	if not t:eq(#chartplays, count) then
		return
	end

	for _, p in ipairs(chartplays) do
		t:assert(p.rating > 0)
	end

	ctx.db.models.chartplays:update({rating = 0})

	chartplays = ctx.chartplays:getChartplays()
	for _, p in ipairs(chartplays) do
		t:eq(p.rating, 0)
	end

	ctx.charts_computer:computeChartplay(chartplays[1])
	ctx.charts_computer:computeChartplay(chartplays[2])

	chartplays = ctx.chartplays:getChartplays()
	t:assert(chartplays[1].rating > 0)
	t:assert(chartplays[2].rating > 0)
	t:assert(chartplays[3].rating == 0)
	t:assert(chartplays[4].rating == 0)
end

---@param t testing.T
function test.chartdiffs_full(t)
	local ctx = create_test_ctx()
end

return test
