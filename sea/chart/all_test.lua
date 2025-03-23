local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartplays = require("sea.chart.Chartplays")
local ILeaderboardsRepo = require("sea.leaderboards.repos.ILeaderboardsRepo")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local TableStorage = require("sea.chart.storage.TableStorage")
local FakeChartplayComputer = require("sea.chart.FakeChartplayComputer")
local FakeSubmissionClientRemote = require("sea.remotes.FakeSubmissionClientRemote")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")

local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local User = require("sea.access.User")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local charts_repo = ChartsRepo(models)

	local fakeChartplayComputer = FakeChartplayComputer()
	local leaderboards = Leaderboards(ILeaderboardsRepo())

	local chartplays = Chartplays(
		charts_repo,
		fakeChartplayComputer,
		TableStorage(),
		TableStorage(),
		leaderboards
	)

	local user = User()
	user.id = 1

	return {
		db = db,
		charts_repo = charts_repo,
		leaderboards = leaderboards,
		chartplays = chartplays,
		user = user,
	}
end

---@param t testing.T
function test.submit_score(t)
	local ctx = create_test_ctx()

	local chartfile_data = "chart"
	local replayfile_data = "replay"

	local remote = FakeSubmissionClientRemote(chartfile_data, replayfile_data)

	local chartplay_values = Chartplay()
	chartplay_values.hash = md5.sumhexa(chartfile_data)
	chartplay_values.index = 1
	chartplay_values.modifiers = {}
	chartplay_values.rate = 1
	chartplay_values.mode = "mania"
	chartplay_values.events_hash = md5.sumhexa(replayfile_data)
	chartplay_values.notes_hash = "notes_hash"

	local user = User()
	user.id = 1

	local chartplay, err = ctx.chartplays:submit(user, remote, chartplay_values)

	if t:assert(chartplay, err) then
		---@cast chartplay -?
		t:assert(chartplay.user_id)
		t:assert(chartplay.compute_state == "valid")
	end
end

return test
