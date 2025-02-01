local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local User = require("sea.access.User")

local test = {}

---@param t testing.T
function test.all(t)
	local db = ServerSqliteDatabase()
	db:remove()
	db:open()

	local models = db.models

	local user = User({id = 1})

	local leaderboard = Leaderboard()
	leaderboard.name = "osu!mania ranked 4K"

	local leaderboards = Leaderboards()
	leaderboard = leaderboards:create(user, leaderboard)

	-- leaderboard_user:calculateRating() for 4K osu ranked Leaderboard
end

return test
