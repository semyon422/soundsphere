local table_util = require("table_util")
local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartdiff = require("sea.chart.Chartdiff")
local Chartplays = require("sea.chart.Chartplays")
local TableStorage = require("sea.chart.storage.TableStorage")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")
local FakeComputeDataProvider = require("sea.compute.FakeComputeDataProvider")
local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ChartfilesRepo = require("sea.chart.repos.ChartfilesRepo")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local User = require("sea.access.User")
local Replay = require("sea.replays.Replay")
local ReplayCoder = require("sea.replays.ReplayCoder")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")
local InputMode = require("ncdk.InputMode")

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

	local charts_storage = TableStorage()
	local replays_storage = TableStorage()

	local compute_data_provider = ComputeDataProvider(chartfiles_repo, charts_storage, replays_storage)
	local compute_data_loader = ComputeDataLoader(compute_data_provider)

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

---@type rizu.ReplayFrame[]
local frames = {
	{time = 0.01, event = VirtualInputEvent(1, true, 2)},
	{time = 0.1, event = VirtualInputEvent(1, false, 2)},
	{time = 0.95, event = VirtualInputEvent(1, true, 3)},
	{time = 1.1, event = VirtualInputEvent(1, false, 3)},
}

---@type sea.Replay
local replay = {
	version = 2,
	timing_values = assert(TimingValuesFactory:get(Timings("osuod", 8))),
	frames = frames,
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
	timings = Timings("osuod", 8),
	subtimings = Subtimings("scorev", 1),
	healths = nil,
	columns_order = {4, 1, 2, 3},
	--
	custom = false,
	const = false,
	pause_count = 0,
	rate_type = "linear",
}
setmetatable(replay, Replay)
local _replayfile_data = ReplayCoder.encode(replay)

local _chartplay_values = {
	hash = replay.hash,
	index = replay.index,
	modifiers = replay.modifiers,
	rate = replay.rate,
	mode = replay.mode,
	--
	nearest = replay.nearest,
	tap_only = replay.tap_only,
	timings = replay.timings,
	subtimings = replay.subtimings,
	healths = replay.healths,
	columns_order = replay.columns_order,
	--
	custom = replay.custom,
	const = replay.const,
	pause_count = replay.pause_count,
	created_at = replay.created_at,
	rate_type = replay.rate_type,
	--
	accuracy = 0.059305293410162315815,
	replay_hash = md5.sumhexa(_replayfile_data),
	judges = {1, 0, 1, 0, 0, 3},
	max_combo = 2,
	miss_count = 3,
	not_perfect_count = 4,
	rating = 0.0037594122723929000729,
	rating_msd = 0.20617003738880157471,
	rating_pp = 0,
	pass = true,
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
	msd_diff = 1.7960339784622192383,
	msd_diff_data = {
		overall = 1.7960339784622192383,
		stream = 1.7960339784622192383,
		jumpstream = 1.2650580406188964844,
		handstream = 1.2186338901519775391,
		stamina = 1.3666554689407348633,
		jackspeed = 0.15087868273258209229,
		chordjack = 1.1722098588943481445,
		technical = 1.357906341552734375,
	},
	msd_diff_rates = {},
	user_diff = 0,
	user_diff_data = "",
	notes_preview = string.char(1, 0, 0, 64, 0, 193, 64, 194, 64, 196, 64, 200, 64, 4, 193),
}
setmetatable(_chartdiff_values, Chartdiff)
---@cast _chartdiff_values sea.Chartdiff

---@param t testing.T
function test.submit_valid_score(t)
	local ctx = create_test_ctx()

	local replayfile_data_table = setmetatable(table_util.copy(replay), Replay)
	local replayfile_data = _replayfile_data
	t:assert(replayfile_data_table:validate())

	local compute_data_provider = FakeComputeDataProvider(chartfile_name, chartfile_data, replayfile_data)
	local compute_data_loader = ComputeDataLoader(compute_data_provider)

	local chartplay_values = setmetatable(table_util.copy(_chartplay_values), Chartplay)
	local chartdiff_values = setmetatable(table_util.copy(_chartdiff_values), Chartdiff)

	local valid, errs = chartplay_values:validate()
	t:tdeq({valid, errs}, {true})

	local valid, errs = chartdiff_values:validate()
	t:tdeq({valid, errs}, {true})

	local user = User()
	user.id = 1

	local c, err = ctx.chartplays:submit(user, 0, compute_data_loader, chartplay_values, chartdiff_values)

	if t:assert(c, err) then
		---@cast c -?
		t:assert(c.chartplay.user_id)
		t:assert(c.chartplay.compute_state == "valid")
	end

	c, err = ctx.chartplays:submit(user, 0, compute_data_loader, chartplay_values, chartdiff_values)
	t:eq(c, nil)
	t:eq(err, "can submit: rate limit")

	local interval = ctx.chartplays.chartplays_access.submit_interval
	c, err = ctx.chartplays:submit(user, interval, compute_data_loader, chartplay_values, chartdiff_values)
	t:assert(c, err)
end

return test
