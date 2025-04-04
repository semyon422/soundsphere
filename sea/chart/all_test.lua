local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartplays = require("sea.chart.Chartplays")
local ILeaderboardsRepo = require("sea.leaderboards.repos.ILeaderboardsRepo")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local TableStorage = require("sea.chart.storage.TableStorage")
local FakeChartplayComputer = require("sea.chart.FakeChartplayComputer")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local FakeSubmissionClientRemote = require("sea.chart.remotes.FakeSubmissionClientRemote")
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
	---@cast remote -sea.FakeSubmissionClientRemote, +sea.SubmissionClientRemote

	local chartplay_values = {
		accuracy = 0.02,
		accuracy_etterna = 0,
		accuracy_osu = 0,
		const = false,
		created_at = os.time(),
		custom = false,
		events_hash = md5.sumhexa(replayfile_data),
		hash = md5.sumhexa(chartfile_data),
		healths = Healths("simple", 20),
		index = 1,
		judges = {},
		max_combo = 0,
		miss_count = 100,
		mode = "mania",
		modifiers = {},
		nearest = false,
		pause_count = 1,
		perfect_count = 10,
		rate = 1,
		rate_type = "exp",
		rating = 0,
		rating_msd = 0,
		rating_pp = 0,
		result = "pass",
		tap_only = false,
		timings = Timings("simple", 20),
	}
	setmetatable(chartplay_values, Chartplay)
	---@cast chartplay_values sea.Chartplay

	local valid, errs = chartplay_values:validate()
	t:tdeq({valid, errs}, {true})

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
