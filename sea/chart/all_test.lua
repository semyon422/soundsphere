local md5 = require("md5")
local json = require("json")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local Chartmeta = require("sea.chart.Chartmeta")
local Chartplays = require("sea.chart.Chartplays")
local ILeaderboardsRepo = require("sea.leaderboards.repos.ILeaderboardsRepo")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local TableStorage = require("sea.chart.storage.TableStorage")
local FakeChartplayComputer = require("sea.chart.FakeChartplayComputer")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
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

local chartfile_name = "chart.sph"
local chartfile_data = [[
# metadata
title Title
artist Artist
name Name
creator Creator
audio audio.mp3
input 4key

# notes
1000 =0
0100
0010
0001
1000 =0
]]

local replayfile_data_table = {
	version = 1,
	timing_values = TimingValuesFactory:get(Timings("sphere"), Subtimings("none")),
	events = "",
	created_at = 0,
	--
	hash = md5.sumhexa(chartfile_data),
	index = 1,
	modifiers = {},
	rate = 1,
	mode = "mania",
	--
	nearest = true,
	tap_only = false,
	timings = Timings("sphere"),
	subtimings = Subtimings("none"),
	healths = Healths("simple", 20),
	columns_order = nil,
	--
	custom = false,
	const = false,
	pause_count = 0,
	rate_type = "linear",
}
---@cast replayfile_data_table sea.Replay
local replayfile_data = json.encode(replayfile_data_table)

---@param t testing.T
function test.submit_score(t)
	local ctx = create_test_ctx()

	local remote = FakeSubmissionClientRemote(chartfile_name, chartfile_data, replayfile_data)
	---@cast remote -sea.FakeSubmissionClientRemote, +sea.SubmissionClientRemote

	local chartplay_values = {
		hash = replayfile_data_table.hash,
		index = replayfile_data_table.index,
		modifiers = replayfile_data_table.modifiers,
		rate = replayfile_data_table.rate,
		mode = replayfile_data_table.mode,
		--
		nearest = replayfile_data_table.nearest,
		tap_only = replayfile_data_table.tap_only,
		timings = replayfile_data_table.timings,
		subtimings = replayfile_data_table.subtimings,
		healths = replayfile_data_table.healths,
		columns_order = replayfile_data_table.columns_order,
		--
		custom = replayfile_data_table.custom,
		const = replayfile_data_table.const,
		pause_count = replayfile_data_table.pause_count,
		created_at = replayfile_data_table.created_at,
		rate_type = replayfile_data_table.rate_type,
		--
		accuracy = 0.02,
		accuracy_etterna = 0,
		accuracy_osu = 0,
		replay_hash = md5.sumhexa(replayfile_data),
		judges = {},
		max_combo = 0,
		miss_count = 100,
		perfect_count = 10,
		rating = 0,
		rating_msd = 0,
		rating_pp = 0,
		result = "pass",
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
		mode = "mania",
		inputmode = "4key",
		duration = 100,
		start_time = 0,
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
		notes_preview = "",
	}
	setmetatable(chartdiff_values, Chartdiff)
	---@cast chartdiff_values sea.Chartdiff

	local valid, errs = chartdiff_values:validate()
	t:tdeq({valid, errs}, {true})

	local chartmeta_values = {
		hash = md5.sumhexa(chartfile_data),
		index = 1,
		timings = Timings("simple"),
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
	}
	setmetatable(chartmeta_values, Chartmeta)
	---@cast chartmeta_values sea.Chartmeta

	local valid, errs = chartmeta_values:validate()
	t:tdeq({valid, errs}, {true})

	ctx.fakeChartplayComputer.chartplay = chartplay_values
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
