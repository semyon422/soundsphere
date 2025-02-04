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

	local leaderboards = Leaderboards(leaderboards_repo)
	local leaderboard, err = leaderboards:create(user, leaderboard)

	if not t:assert(leaderboard, err) then
		return
	end
	---@cast leaderboard -?

	local chartplays = leaderboards_repo:getBestChartplays(leaderboard, user)

	-- leaderboard_user:calculateRating() for 4K osu ranked Leaderboard
end

return test
