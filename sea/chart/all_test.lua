local table_util = require("table_util")
local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local Chartplays = require("sea.chart.Chartplays")
local ILeaderboardsRepo = require("sea.leaderboards.repos.ILeaderboardsRepo")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local TableStorage = require("sea.chart.storage.TableStorage")
local ChartplayComputer = require("sea.chart.ChartplayComputer")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local FakeSubmissionClientRemote = require("sea.chart.remotes.FakeSubmissionClientRemote")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")

local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local User = require("sea.access.User")
local Replay = require("sea.replays.Replay")
local ReplayCoder = require("sea.replays.ReplayCoder")
local ReplayEvents = require("sea.replays.ReplayEvents")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local charts_repo = ChartsRepo(models)

	local chartplayComputer = ChartplayComputer()
	local leaderboards = Leaderboards(ILeaderboardsRepo())

	local chartplays = Chartplays(
		charts_repo,
		chartplayComputer,
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
1000 =4
]]

local _events = {
	{0.01, 1, true},
	{0.1, 1, false},
	{0.99, 2, true},
	{1.1, 2, false},
}

local _replayfile_data_table = {
	version = 1,
	timing_values = TimingValuesFactory:get(Timings("sphere")),
	events = ReplayEvents.encode(_events),
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
	subtimings = nil,
	healths = nil,
	columns_order = nil,
	--
	custom = false,
	const = false,
	pause_count = 0,
	rate_type = "linear",
}
setmetatable(_replayfile_data_table, Replay)
---@cast _replayfile_data_table sea.Replay
local _replayfile_data = ReplayCoder.encode(_replayfile_data_table)

local _chartplay_values = {
	hash = _replayfile_data_table.hash,
	index = _replayfile_data_table.index,
	modifiers = _replayfile_data_table.modifiers,
	rate = _replayfile_data_table.rate,
	mode = _replayfile_data_table.mode,
	--
	nearest = _replayfile_data_table.nearest,
	tap_only = _replayfile_data_table.tap_only,
	timings = _replayfile_data_table.timings,
	subtimings = _replayfile_data_table.subtimings,
	healths = _replayfile_data_table.healths,
	columns_order = _replayfile_data_table.columns_order,
	--
	custom = _replayfile_data_table.custom,
	const = _replayfile_data_table.const,
	pause_count = _replayfile_data_table.pause_count,
	created_at = _replayfile_data_table.created_at,
	rate_type = _replayfile_data_table.rate_type,
	--
	accuracy = 0.020270363958551557,
	replay_hash = md5.sumhexa(_replayfile_data),
	judges = {2, 0},
	max_combo = 2,
	miss_count = 3,
	rating = 0,
	rating_msd = 0,
	rating_pp = 0,
	result = "pass",
}
setmetatable(_chartplay_values, Chartplay)
---@cast _chartplay_values sea.Chartplay

local _chartdiff_values = {
	hash = md5.sumhexa(chartfile_data),
	index = 1,
	modifiers = {},
	rate = 1,
	mode = "mania",
	inputmode = "4key",
	duration = 4,
	start_time = 0,
	notes_count = 5,
	judges_count = 5,
	note_types_count = {hold = 0, tap = 5},
	density_data = {},
	sv_data = {},
	enps_diff = 0.0091578194443670893,
	osu_diff = 0.30224240623872012,
	msd_diff = 0,
	msd_diff_data = "",
	user_diff = 0,
	user_diff_data = "",
	notes_preview = string.char(1, 0, 0, 64, 0, 193, 64, 194, 64, 196, 64, 200, 64, 4, 193),
}
setmetatable(_chartdiff_values, Chartdiff)
---@cast _chartdiff_values sea.Chartdiff

---@param t testing.T
function test.submit_valid_score(t)
	local ctx = create_test_ctx()

	local replayfile_data_table = setmetatable(table_util.copy(_replayfile_data_table), Replay)
	local replayfile_data = _replayfile_data
	t:assert(replayfile_data_table:validate())

	local remote = FakeSubmissionClientRemote(chartfile_name, chartfile_data, replayfile_data)
	---@cast remote -sea.FakeSubmissionClientRemote, +sea.SubmissionClientRemote

	local chartplay_values = setmetatable(table_util.copy(_chartplay_values), Chartplay)
	local chartdiff_values = setmetatable(table_util.copy(_chartdiff_values), Chartdiff)

	local valid, errs = chartplay_values:validate()
	t:tdeq({valid, errs}, {true})

	local valid, errs = chartdiff_values:validate()
	t:tdeq({valid, errs}, {true})

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
