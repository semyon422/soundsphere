local LeaderboardDifftable = require("sea.leaderboards.LeaderboardDifftable")

---@type rdb.ModelOptions
local leaderboard_difftables = {}

leaderboard_difftables.metatable = LeaderboardDifftable

leaderboard_difftables.relations = {
	leaderboard = {belongs_to = "leaderboards", key = "leaderboard_id"},
	difftable = {belongs_to = "difftables", key = "difftable_id"},
}

return leaderboard_difftables
