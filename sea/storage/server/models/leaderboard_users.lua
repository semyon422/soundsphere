local LeaderboardUser = require("sea.leaderboards.LeaderboardUser")

---@type rdb.ModelOptions
local leaderboard_users = {}

leaderboard_users.metatable = LeaderboardUser

return leaderboard_users
