local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local LeaderboardsRepo = require("sea.storage.server.repos.LeaderboardsRepo")
local User = require("sea.access.User")

local test = {}

---@param t testing.T
function test.all(t)
	local db = ServerSqliteDatabase()
	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local leaderboards_repo = LeaderboardsRepo(models)

	local user = User({id = 1})

	local leaderboard = Leaderboard()
	leaderboard.name = "osu!mania ranked 4K"
	leaderboard.ranked_lists = {1}

	local leaderboards = Leaderboards(leaderboards_repo)
	local leaderboard, err = leaderboards:create(user, leaderboard)

	if not t:assert(leaderboard, err) then
		return
	end
	---@cast leaderboard -?

	models.chartplays:create({
		user_id = user.id,
		hash = "",
		index = 1,
		modifiers = "{}",
		rate = 1000,
		mode = "mania",
		rating = 1,
		result = "fail",
	})
	models.chartplays:create({
		user_id = user.id,
		hash = "",
		index = 1,
		modifiers = "{}",
		rate = 1000,
		mode = "mania",
		rating = 2,
		result = "fail",
	})

	local ranked_list = models.ranked_lists:create({
		name = "osu!mania ranked"
	})

	models.ranked_list_chartmetas:create({
		ranked_list_id = ranked_list.id,
		hash = "",
		index = 1,
	})

	local chartplays = leaderboards_repo:getBestChartplays(leaderboard, user)

	if t:eq(#chartplays, 1) then
		t:eq(chartplays[1].rating, 2)
	end

	-- leaderboard_user:calculateRating() for 4K osu ranked Leaderboard
end

return test
