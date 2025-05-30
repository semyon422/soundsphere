local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local User = require("sea.access.User")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Chartmeta = require("sea.chart.Chartmeta")
local Chartplay = require("sea.chart.Chartplay")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local DanClearsRepo = require("sea.dan.repos.DanClearsRepo")
local Dans = require("sea.dan.Dans")
local dan_list = require("sea.dan.dan_list")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	local models = db.models
	local charts_repo = ChartsRepo(models)
	local dan_clears_repo = DanClearsRepo(models)

	local user = User()
	user.id = 1
	user.play_time = 1e6

	return {
		db = db,
		user = user,
		dans = Dans(charts_repo, dan_clears_repo),
		charts_repo = charts_repo,
	}
end

local bms_chartplay = {
	user_id = 1,
	compute_state = "valid",
	computed_at = 0,
	submitted_at = 0,
	hash = "",
	index = 1,
	rate = 1,
	mode = "mania",
	nearest = false,
	tap_only = false,
	timings = Timings("bmsrank", 1),
	custom = false,
	const = false,
	pause_count = 0,
	created_at = 0,
	rate_type = "linear",
	accuracy = 0,
	replay_hash = "",
	judges = {},
	max_combo = 0,
	miss_count = 0,
	not_perfect_count = 0,
	rating = 0,
	rating_msd = 0,
	rating_pp = 0,
	pass = true,
}
setmetatable(bms_chartplay, Chartplay)
---@cast bms_chartplay sea.Chartplay

---@param t testing.T
function test.is_dan(t)
	local dans = Dans()

	local random = Chartmeta()
	random.hash = "123456789"

	local delta_dan = Chartmeta()
	delta_dan.hash = "6432f864b074264c230604cfe142edb0"

	t:eq(dans:isDan(random), false)
	t:eq(dans:isDan(delta_dan), true)

	local alpha_dan = dan_list[11]
	t:eq(dans:isDan(alpha_dan.chartmetas[1]), true)

	local bms_1st_chart = Chartmeta()
	bms_1st_chart.hash = "test1"
	local bms_4th_chart = Chartmeta()
	bms_4th_chart.hash = "test4"
	t:eq(dans:isDan(bms_1st_chart), false)
	t:eq(dans:isDan(bms_4th_chart), true)
end

---@param t testing.T
function test.submit_dan(t)
	local ctx = create_test_ctx()
	local time = 5000

	--chartplay.accuracy = 0.025 -- 79.94%
	--chartplay.accuracy = 0.024 -- 81.75%

	local delta_dan_chartmeta = Chartmeta()
	delta_dan_chartmeta.hash = "6432f864b074264c230604cfe142edb0"

	local chartplay = Chartplay()
	chartplay.id = 1
	chartplay.rate = 1
	chartplay.accuracy = 0.025 -- not a clear
	chartplay.timings = Timings("osuod", 0) -- wrong timings
	chartplay.subtimings = Subtimings("scorev", 1)
	chartplay.pause_count = 1

	local _, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	t:eq(err, "pauses are not allowed")

	chartplay.pause_count = 0
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	t:eq(err, "unsuitable timings")

	chartplay.timings = Timings("osuod", 9)
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	t:eq(err, "not cleared")

	chartplay.accuracy = 0.024
	local dan_clear, _ = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	---@cast dan_clear -?

	t:eq(dan_clear.time, time)
	t:eq(dan_clear.user_id, ctx.user.id)
	t:eq(dan_clear.dan_id, dan_list[14].id)
	t:eq(dan_clear.chartplay_ids[1], chartplay.id)
	t:eq(dan_clear.rate, 1)

	chartplay = Chartplay()
	chartplay.id = 2
	chartplay.rate = 1
	chartplay.accuracy = 0.02
	chartplay.timings = Timings("osuod", 9)
	chartplay.subtimings = Subtimings("scorev", 1)
	chartplay.pause_count = 0
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	t:eq(err, "already cleared")

	chartplay.rate = 1.05
	dan_clear, _ = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartmeta, time)
	t:assert(dan_clear ~= nil)
	---@cast dan_clear -?

	t:eq(dan_clear.time, time)
	t:eq(dan_clear.user_id, ctx.user.id)
	t:eq(dan_clear.dan_id, dan_list[14].id)
	t:eq(dan_clear.chartplay_ids[1], chartplay.id)
	t:eq(dan_clear.rate, 1.05)
end

---@param t testing.T
function test.submit_bms_dan(t)
	local ctx = create_test_ctx()
	local time = 5000

	local dan = dan_list[99999]

	local cm = Chartmeta()
	cm.hash = dan.chartmetas[#dan.chartmetas].hash

	local chartplay = Chartplay()
	chartplay.id = 1
	chartplay.rate = 1
	chartplay.miss_count = 0
	chartplay.accuracy = 0.02
	chartplay.timings = Timings("bmsrank", 1)
	chartplay.pause_count = 0

	local _, err = ctx.dans:submit(ctx.user, chartplay, cm, time)
	t:eq(err, "invalid chartplay order")

	bms_chartplay.modifiers = {}
	bms_chartplay.hash = dan.chartmetas[3].hash
	bms_chartplay.submitted_at = 1
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[2].hash
	bms_chartplay.submitted_at = 2
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[1].hash
	bms_chartplay.submitted_at = 3
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[4].hash
	bms_chartplay.submitted_at = 4
	ctx.charts_repo:createChartplay(bms_chartplay)

	_, err = ctx.dans:submit(ctx.user, chartplay, cm, time)
	t:eq(err, "invalid chartplay order")

	bms_chartplay.modifiers = {}
	bms_chartplay.hash = dan.chartmetas[1].hash
	bms_chartplay.submitted_at = 5
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[2].hash
	bms_chartplay.submitted_at = 6
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[3].hash
	bms_chartplay.submitted_at = 7
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[4].hash
	bms_chartplay.submitted_at = 8
	ctx.charts_repo:createChartplay(bms_chartplay)

	local dan_clear, _ = ctx.dans:submit(ctx.user, bms_chartplay, cm, time)
	---@cast dan_clear -?
	t:eq(dan_clear.dan_id, dan.id)

	bms_chartplay.modifiers = {}
	bms_chartplay.hash = dan.chartmetas[1].hash
	bms_chartplay.submitted_at = 9
	bms_chartplay.miss_count = 100
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[2].hash
	bms_chartplay.submitted_at = 10
	bms_chartplay.miss_count = 100
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[3].hash
	bms_chartplay.submitted_at = 11
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[4].hash
	bms_chartplay.submitted_at = 12
	bms_chartplay.miss_count = 100
	ctx.charts_repo:createChartplay(bms_chartplay)

	_, err = ctx.dans:submit(ctx.user, bms_chartplay, cm, time)
	t:eq(err, "not cleared")
end

---@param t testing.T
function test.mods(t)
	local ctx = create_test_ctx()
	local time = 5000

	local chartmeta = Chartmeta()
	chartmeta.hash = "6432f864b074264c230604cfe142edb0"

	local chartplay = Chartplay()
	chartplay.id = 1
	chartplay.rate = 1
	chartplay.accuracy = 0.02
	chartplay.timings = Timings("osuod", 9)
	chartplay.subtimings = Subtimings("scorev", 1)
	chartplay.pause_count = 0
	chartplay.modifiers = { { id = 1 } }
	local _, err = ctx.dans:submit(ctx.user, chartplay, chartmeta, time)
	t:eq(err, "modifiers are not allowed")

	chartplay.modifiers = {}
	chartplay.columns_order = { 1, 3, 2, 4 }
	_, err = ctx.dans:submit(ctx.user, chartplay, chartmeta, time)
	t:eq(err, "invalid column order")

	chartplay.columns_order = { 2, 1, 3, 4 }
	_, err = ctx.dans:submit(ctx.user, chartplay, chartmeta, time)
	t:eq(err, "invalid column order")

	chartplay.columns_order = { 4, 3, 2, 1 }
	local dan_clear, _ = ctx.dans:submit(ctx.user, chartplay, chartmeta, time)
	t:assert(dan_clear ~= nil)
end

---@param t testing.T
function test.bms_mods(t)
	local ctx = create_test_ctx()
	local time = 5000

	local dan = dan_list[99999]

	local cm = Chartmeta()
	cm.hash = dan.chartmetas[#dan.chartmetas].hash

	local chartplay = Chartplay()
	chartplay.id = 1
	chartplay.rate = 1
	chartplay.miss_count = 0
	chartplay.accuracy = 0.02
	chartplay.timings = Timings("bmsrank", 1)
	chartplay.pause_count = 0

	bms_chartplay.modifiers = {}
	bms_chartplay.hash = dan.chartmetas[1].hash
	bms_chartplay.submitted_at = 1
	bms_chartplay.modifiers = { { id = 2 } }
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[2].hash
	bms_chartplay.submitted_at = 2
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[3].hash
	bms_chartplay.submitted_at = 3
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[4].hash
	bms_chartplay.submitted_at = 4
	ctx.charts_repo:createChartplay(bms_chartplay)

	local _, err = ctx.dans:submit(ctx.user, chartplay, cm, time)
	t:eq(err, "modifiers are not allowed")

	bms_chartplay.modifiers = {}
	bms_chartplay.hash = dan.chartmetas[1].hash
	bms_chartplay.submitted_at = 5
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[2].hash
	bms_chartplay.submitted_at = 6
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[3].hash
	bms_chartplay.submitted_at = 7
	bms_chartplay.rate = 1.06
	ctx.charts_repo:createChartplay(bms_chartplay)
	bms_chartplay.hash = dan.chartmetas[4].hash
	bms_chartplay.submitted_at = 8
	ctx.charts_repo:createChartplay(bms_chartplay)

	_, err = ctx.dans:submit(ctx.user, chartplay, cm, time)
	t:eq(err, "different rates in chartplays")
end

return test
