local LeaderboardUser = require("sea.leaderboards.LeaderboardUser")

---@type rdb.ModelOptions
local leaderboard_users = {}

leaderboard_users.metatable = LeaderboardUser

leaderboard_users.relations = {
	user = {belongs_to = "users", key = "user_id"},
	leaderboard = {belongs_to = "leaderboards", key = "leaderboard_id"},
}

return leaderboard_users
