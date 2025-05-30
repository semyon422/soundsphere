local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local User = require("sea.access.User")
local Timings = require("sea.chart.Timings")
local Chartdiff = require("sea.chart.Chartdiff")
local Chartplay = require("sea.chart.Chartplay")
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
	local dan_clears_repo = DanClearsRepo(models)

	local user = User()
	user.id = 1
	user.play_time = 1e6

	return {
		db = db,
		user = user,
		dans = Dans(dan_clears_repo)
	}
end

---@param t testing.T
function test.is_dan(t)
	local dans = Dans()

	local random = Chartdiff()
	random.hash = "123456789"

	local delta_dan = Chartdiff()
	delta_dan.hash = "6432f864b074264c230604cfe142edb0"

	t:eq(dans:isDan(random), false)
	t:eq(dans:isDan(delta_dan), true)

	local alpha_dan = dan_list[11]
	t:eq(dans:isDan(alpha_dan.chartdiffs[1]), true)
end

---@param t testing.T
function test.submit_dan(t)
	local ctx = create_test_ctx()
	local time = 5000

	--chartplay.accuracy = 0.025 -- 79.94%
	--chartplay.accuracy = 0.024 -- 81.75%

	local delta_dan_chartdiff = Chartdiff()
	delta_dan_chartdiff.hash = "6432f864b074264c230604cfe142edb0"

	local chartplay = Chartplay()
	chartplay.id = 1
	chartplay.rate = 1
	chartplay.accuracy = 0.025 -- not a clear
	chartplay.timings = Timings("osuod", 0) -- wrong timings
	chartplay.pause_count = 1

	local _, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:eq(err, "pauses are not allowed")

	chartplay.pause_count = 0
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:eq(err, "unsuitable timings")

	chartplay.timings = Timings("osuod", 9)
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:eq(err, "not cleared")

	chartplay.accuracy = 0.024
	local dan_clear, _ = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:assert(dan_clear ~= nil)
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
	chartplay.pause_count = 0
	_, err = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:eq(err, "already cleared")

	chartplay.rate = 1.05
	dan_clear, _ = ctx.dans:submit(ctx.user, chartplay, delta_dan_chartdiff, time)
	t:assert(dan_clear ~= nil)
	---@cast dan_clear -?

	t:eq(dan_clear.time, time)
	t:eq(dan_clear.user_id, ctx.user.id)
	t:eq(dan_clear.dan_id, dan_list[14].id)
	t:eq(dan_clear.chartplay_ids[1], chartplay.id)
	t:eq(dan_clear.rate, 1.05)
end

return test
