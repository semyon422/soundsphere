local LeaderboardUser = require("sea.leaderboards.LeaderboardUser")

---@type rdb.ModelOptions
local leaderboard_users = {}

leaderboard_users.table_name = "leaderboard_users"

leaderboard_users.types = {}

leaderboard_users.relations = {}

function leaderboard_users:from_db()
	return setmetatable(self, LeaderboardUser)
end

return leaderboard_users
