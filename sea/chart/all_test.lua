local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local Chartmeta = require("sea.chart.Chartmeta")
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
		fakeChartplayComputer = fakeChartplayComputer,
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

	local chartdiff_values = {
		hash = md5.sumhexa(chartfile_data),
		index = 1,
		modifiers = {},
		rate = 1,
		rate_type = "exp",
		mode = "mania",
		inputmode = "4key",
		notes_count = 100,
		judges_count = 110,
		note_types_count = {},
		density_data = {},
		sv_data = {},
		enps_diff = 0,
		osu_diff = 0,
		msd_diff = 0,
		msd_diff_data = "",
		user_diff = 0,
		user_diff_data = "",
	}
	setmetatable(chartdiff_values, Chartdiff)
	---@cast chartdiff_values sea.Chartdiff

	local valid, errs = chartdiff_values:validate()
	t:tdeq({valid, errs}, {true})

	local chartmeta_values = {
		hash = md5.sumhexa(chartfile_data),
		index = 1,
		timings = Timings("simple", 100),
		healths = Healths("simple", 20),
		title = "Title",
		title_unicode = "Title Unicode",
		artist = "Artist",
		artist_unicode = "Artist Unicode",
		name = "Name",
		creator = "Creator",
		level = 10,
		inputmode = "4key",
		source = "",
		tags = "",
		format = "osu",
		audio_path = "",
		background_path = "",
		preview_time = 10,
		tempo = 120,
		duration = 180,
	}
	setmetatable(chartmeta_values, Chartmeta)
	---@cast chartmeta_values sea.Chartmeta

	local valid, errs = chartmeta_values:validate()
	t:tdeq({valid, errs}, {true})

	ctx.fakeChartplayComputer.chartdiff = chartdiff_values
	ctx.fakeChartplayComputer.chartmeta = chartmeta_values

	local user = User()
	user.id = 1

	local chartplay, err = ctx.chartplays:submit(user, remote, chartplay_values, chartdiff_values)

	if t:assert(chartplay, err) then
		---@cast chartplay -?
		t:assert(chartplay.user_id)
		t:assert(chartplay.compute_state == "valid")
	end
end

return test
