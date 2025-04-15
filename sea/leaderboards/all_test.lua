local table_util = require("table_util")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local LeaderboardDifftable = require("sea.leaderboards.LeaderboardDifftable")
local LeaderboardsRepo = require("sea.leaderboards.repos.LeaderboardsRepo")
local User = require("sea.access.User")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local leaderboards_repo = LeaderboardsRepo(models)

	local user = User()
	user.id = 1

	local leaderboard = Leaderboard()
	leaderboard.name = "Leaderboard 1"

	local leaderboards = Leaderboards(leaderboards_repo)
	local leaderboard, err = assert(leaderboards:create(user, leaderboard))
	leaderboard = leaderboards:getLeaderboard(leaderboard.id)

	assert(leaderboard, err)

	return {
		db = db,
		leaderboards_repo = leaderboards_repo,
		user = user,
		leaderboard = leaderboard,
		leaderboards = leaderboards,
	}
end

local function lb_update_select(ctx)
	ctx.leaderboards:update(ctx.user, ctx.leaderboard.id, ctx.leaderboard)
	ctx.leaderboard = ctx.leaderboards:getLeaderboard(ctx.leaderboard.id)
end

---@param ctx {db: sea.ServerSqliteDatabase, user: sea.User}
---@param values {[string]: any}
local function create_chartplay(ctx, values)
	local chartplay = table_util.copy(values)
	chartplay.user_id = values.user_id or ctx.user.id
	chartplay.hash = values.hash or ""
	chartplay.index = 1
	chartplay.modifiers = values.modifiers or {}
	chartplay.rate = values.rate or 1
	chartplay.mode = values.mode or "mania"
	chartplay.rating = values.rating or 0
	chartplay.result = values.result or "fail"
	chartplay.timings = values.timings or Timings("simple", 0.1)
	chartplay.subtimings = values.subtimings
	return ctx.db.models.chartplays:create(chartplay)
end

---@param t testing.T
function test.best_score_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, hash = "1"})
	create_chartplay(ctx, {rating = 2, hash = "1"})
	create_chartplay(ctx, {rating = 3, hash = "2"})
	create_chartplay(ctx, {rating = 4, hash = "2"})

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 2) then
		t:eq(chartplays[1].rating, 4)
		t:eq(chartplays[2].rating, 2)
	end
end

---@param t testing.T
function test.user_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, user_id = 1})
	create_chartplay(ctx, {rating = 2, user_id = 2})

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, 1)

	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, 2)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end
end

---@param t testing.T
function test.nearest_filter_single(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, nearest = true, hash = ""})
	create_chartplay(ctx, {rating = 2, nearest = false, hash = ""})

	ctx.leaderboard.nearest = "any"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 1)

	ctx.leaderboard.nearest = "disabled"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.nearest = "enabled"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.nearest_filter_multiple(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, nearest = true, hash = "1"})
	create_chartplay(ctx, {rating = 2, nearest = false, hash = "2"})

	ctx.leaderboard.nearest = "any"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.nearest = "disabled"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.nearest = "enabled"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.result_filter(t)
	local ctx = create_test_ctx()

	local _chartplays = {
		create_chartplay(ctx, {rating = 1, result = "pfc"}),
		create_chartplay(ctx, {rating = 2, result = "fc"}),
		create_chartplay(ctx, {rating = 3, result = "pass"}),
		create_chartplay(ctx, {rating = 4, result = "fail"}),
	}

	t:eq(#_chartplays, 4)

	for _, c in ipairs(_chartplays) do
		ctx.leaderboard.result = c.result
		lb_update_select(ctx)

		local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
		if t:eq(#chartplays, 1) then
			t:eq(chartplays[1].rating, c.rating)
		end
	end
end

---@param t testing.T
function test.custom_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, custom = false, hash = "1"})
	create_chartplay(ctx, {rating = 2, custom = true, hash = "2"})

	ctx.leaderboard.allow_custom = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.allow_custom = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.pause_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, pause_count = 0, hash = "1"})
	create_chartplay(ctx, {rating = 2, pause_count = 1, hash = "2"})

	ctx.leaderboard.allow_pause = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.allow_pause = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.reorder_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, columns_order = {}, hash = "1"})
	create_chartplay(ctx, {rating = 2, columns_order = {4, 3, 2, 1}, hash = "2"})

	ctx.leaderboard.allow_reorder = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.allow_reorder = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.modifiers_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, modifiers = {}, hash = "1"})
	create_chartplay(ctx, {rating = 2, modifiers = {"any data here"}, hash = "2"})

	ctx.leaderboard.allow_modifiers = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.allow_modifiers = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.tap_only_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, tap_only = false, hash = "1"})
	create_chartplay(ctx, {rating = 2, tap_only = true, hash = "2"})

	ctx.leaderboard.allow_tap_only = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)

	ctx.leaderboard.allow_tap_only = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.free_timings_filter(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		timings = Timings("simple", 0.1),
		hash = "",
		index = 1,
	})

	create_chartplay(ctx, {rating = 1, timings = Timings("simple", 0.1)})
	create_chartplay(ctx, {rating = 2, timings = Timings("osumania", 8), subtimings = Subtimings("scorev", 1)})

	ctx.leaderboard.allow_free_timings = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.allow_free_timings = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.free_timings_filter_specific(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		timings = Timings("simple", 0.2),
		hash = "",
		index = 1,
	})

	create_chartplay(ctx, {rating = 1, timings = Timings("simple", 0.1)})
	create_chartplay(ctx, {rating = 2, timings = Timings("osumania", 8), subtimings = Subtimings("scorev", 1)})

	ctx.leaderboard.allow_free_timings = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.allow_free_timings = false
	ctx.leaderboard.timings = Timings("simple", 0.1)
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.free_timings_filter_undefined(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		hash = "",
		index = 1,
	})

	create_chartplay(ctx, {rating = 1})

	ctx.leaderboard.allow_free_timings = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 1)

	ctx.leaderboard.allow_free_timings = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 0)
end

---@param t testing.T
function test.free_healths_filter(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		healths = Healths("simple", 10),
		hash = "",
		index = 1,
	})

	create_chartplay(ctx, {rating = 1, healths = Healths("simple", 10)})
	create_chartplay(ctx, {rating = 2, healths = Healths("simple", 20)})

	ctx.leaderboard.allow_free_healths = true
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.allow_free_healths = false
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 1)
	end
end

---@param t testing.T
function test.rate_filter(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		hash = "",
		index = 1,
	})

	create_chartplay(ctx, {rating = 1, rate = 1.0})
	create_chartplay(ctx, {rating = 2, rate = 1.1})
	create_chartplay(ctx, {rating = 3, rate = 1.2})

	ctx.leaderboard.rate = "any"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 3)
	end

	ctx.leaderboard.rate = {1, 1.1}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	ctx.leaderboard.rate = {min = 0.9, max = 1.15}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end
end

---@param t testing.T
function test.chartmeta_inputmode_filter(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartmetas:create({
		hash = "1",
		index = 1,
		inputmode = "4key",
	})

	ctx.db.models.chartmetas:create({
		hash = "2",
		index = 1,
		inputmode = "7key",
	})

	ctx.db.models.chartmetas:create({
		hash = "3",
		index = 1,
		inputmode = "10key",
	})

	create_chartplay(ctx, {rating = 1, hash = "1"})
	create_chartplay(ctx, {rating = 2, hash = "2"})
	create_chartplay(ctx, {rating = 3, hash = "3"})

	ctx.leaderboard.chartmeta_inputmode = {}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 3)

	ctx.leaderboard.chartmeta_inputmode = {"4key", "7key"}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)
end

---@param t testing.T
function test.chartdiff_inputmode_filter(t)
	local ctx = create_test_ctx()

	ctx.db.models.chartdiffs:create({
		hash = "1",
		index = 1,
		inputmode = "4key",
		mode = "mania",
		modifiers = {},
		rate = 1,
	})

	ctx.db.models.chartdiffs:create({
		hash = "2",
		index = 1,
		inputmode = "7key",
		mode = "mania",
		modifiers = {},
		rate = 1,
	})

	ctx.db.models.chartdiffs:create({
		hash = "3",
		index = 1,
		inputmode = "10key",
		mode = "mania",
		modifiers = {},
		rate = 1,
	})

	create_chartplay(ctx, {rating = 1, hash = "1"})
	create_chartplay(ctx, {rating = 2, hash = "2"})
	create_chartplay(ctx, {rating = 3, hash = "3"})

	ctx.leaderboard.chartdiff_inputmode = {}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 3)

	ctx.leaderboard.chartdiff_inputmode = {"4key", "7key"}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	t:eq(#chartplays, 2)
end

---@param t testing.T
function test.difftable_filter_single(t)
	local ctx = create_test_ctx()

	local models = ctx.db.models

	create_chartplay(ctx, {rating = 1, hash = "1"})
	create_chartplay(ctx, {rating = 2, hash = "2"})

	local difftable = models.difftables:create({
		name = "Ranked list 1"
	})

	models.difftable_chartmetas:create({
		difftable_id = difftable.id,
		hash = "2",
		index = 1,
		level = 0,
	})

	ctx.leaderboard.leaderboard_difftables = {{id = 1, leaderboard_id = 1, difftable_id = difftable.id}}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end
end

---@param t testing.T
function test.difftable_filter_multiple(t)
	local ctx = create_test_ctx()

	local models = ctx.db.models

	create_chartplay(ctx, {rating = 1})

	local difftable_1 = models.difftables:create({name = "Ranked list 1"})
	local difftable_2 = models.difftables:create({name = "Ranked list 2"})

	models.difftable_chartmetas:create({
		difftable_id = difftable_1.id,
		hash = "",
		index = 1,
		level = 1,
	})

	models.difftable_chartmetas:create({
		difftable_id = difftable_2.id,
		hash = "",
		index = 1,
		level = 2,
	})

	ctx.leaderboard.leaderboard_difftables = {{id = 1, leaderboard_id = 1, difftable_id = difftable_1.id}}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].difftable_id, 1)
		t:eq(chartplays[1].difftable_level, 1)
	end

	ctx.leaderboard.leaderboard_difftables = {{id = 1, leaderboard_id = 1, difftable_id = difftable_2.id}}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].difftable_id, 2)
		t:eq(chartplays[1].difftable_level, 2)
	end

	ctx.leaderboard.leaderboard_difftables = {
		{id = 1, leaderboard_id = 1, difftable_id = difftable_1.id},
		{id = 1, leaderboard_id = 1, difftable_id = difftable_2.id},
	}
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].difftable_id, 2)
		t:eq(chartplays[1].difftable_level, 2)
	end
end

---@param t testing.T
function test.rating_calc_filter(t)
	local ctx = create_test_ctx()

	create_chartplay(ctx, {rating = 1, rating_pp = 2, hash = "1"})
	create_chartplay(ctx, {rating = 2, rating_pp = 1, hash = "2"})

	ctx.leaderboard.rating_calc = "enps"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 2) then
		t:eq(chartplays[1].rating, 2)
		t:eq(chartplays[1].rating_pp, 1)
	end

	ctx.leaderboard.rating_calc = "pp"
	lb_update_select(ctx)

	local chartplays = ctx.leaderboards_repo:getBestChartplays(ctx.leaderboard, ctx.user.id)
	if t:eq(#chartplays, 2) then
		t:eq(chartplays[1].rating, 1)
		t:eq(chartplays[1].rating_pp, 2)
	end
end

--------------------------------------------------------------------------------

---@param t testing.T
function test.check_chartplay(t)
	local ctx = create_test_ctx()

	local cp1 = create_chartplay(ctx, {rating = 1, nearest = true, hash = ""})
	local cp2 = create_chartplay(ctx, {rating = 2, nearest = false, hash = ""})

	ctx.leaderboard.nearest = "any"
	lb_update_select(ctx)

	t:assert(ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp1))
	t:assert(ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp2))

	ctx.leaderboard.nearest = "disabled"
	lb_update_select(ctx)

	t:assert(not ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp1))
	t:assert(ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp2))

	ctx.leaderboard.nearest = "enabled"
	lb_update_select(ctx)

	t:assert(ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp1))
	t:assert(not ctx.leaderboards_repo:checkChartplay(ctx.leaderboard, cp2))
end

---@param t testing.T
function test.total_rating(t)
	local ctx = create_test_ctx()

	local cp1 = create_chartplay(ctx, {rating = 1, hash = "1"})
	local cp2 = create_chartplay(ctx, {rating = 2, hash = "2"})

	ctx.leaderboard.scores_comb = "avg"
	ctx.leaderboard.scores_comb_count = 10
	lb_update_select(ctx)

	ctx.leaderboards:addChartplay(cp1)

	local lb_user = ctx.db.models.leaderboard_users:find({})
	---@cast lb_user sea.LeaderboardUser

	t:eq(lb_user.total_rating, 0.3)
end

---@param t testing.T
function test.rank(t)
	local ctx = create_test_ctx()

	ctx.leaderboard.scores_comb = "avg"
	ctx.leaderboard.scores_comb_count = 1
	lb_update_select(ctx)

	local cp1 = create_chartplay(ctx, {rating = 1, user_id = 1})
	local cp2 = create_chartplay(ctx, {rating = 2, user_id = 2})

	ctx.leaderboards:addChartplay(cp1)
	ctx.leaderboards:addChartplay(cp2)

	-- recalc all ranks
	ctx.leaderboards:updateLeaderboardUser(ctx.leaderboard, 1)
	ctx.leaderboards:updateLeaderboardUser(ctx.leaderboard, 2)

	local lb_user_1 = ctx.db.models.leaderboard_users:find({user_id = 1})
	---@cast lb_user_1 sea.LeaderboardUser

	t:eq(lb_user_1.total_rating, 1)
	t:eq(lb_user_1.rank, 2)

	local lb_user_2 = ctx.db.models.leaderboard_users:find({user_id = 2})
	---@cast lb_user_2 sea.LeaderboardUser

	t:eq(lb_user_2.total_rating, 2)
	t:eq(lb_user_2.rank, 1)
end

---@param t testing.T
function test.difftables_create(t)
	local ctx = create_test_ctx()

	local lb_dt_1 = LeaderboardDifftable()
	lb_dt_1.difftable_id = 1
	local lb_dt_2 = LeaderboardDifftable()
	lb_dt_2.difftable_id = 2

	ctx.leaderboard.leaderboard_difftables = {lb_dt_1, lb_dt_2}

	ctx.leaderboards:update(ctx.user, ctx.leaderboard.id, ctx.leaderboard)
	ctx.leaderboard = ctx.leaderboards:getLeaderboard(ctx.leaderboard.id)

	t:eq(#ctx.leaderboard.leaderboard_difftables, 2)
	t:eq(ctx.leaderboard.leaderboard_difftables[1].difftable_id, 1)
	t:eq(ctx.leaderboard.leaderboard_difftables[2].difftable_id, 2)

	local lb_dt_3 = LeaderboardDifftable()
	lb_dt_3.difftable_id = 3

	ctx.leaderboard.leaderboard_difftables = {lb_dt_2, lb_dt_3}

	ctx.leaderboards:update(ctx.user, ctx.leaderboard.id, ctx.leaderboard)
	ctx.leaderboard = ctx.leaderboards:getLeaderboard(ctx.leaderboard.id)

	t:eq(#ctx.leaderboard.leaderboard_difftables, 2)
	t:eq(ctx.leaderboard.leaderboard_difftables[1].difftable_id, 2)
	t:eq(ctx.leaderboard.leaderboard_difftables[2].difftable_id, 3)
end

return test
