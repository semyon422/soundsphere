local table_util = require("table_util")
local leaderboard_users = require("sea.storage.server.models.leaderboard_users")
local LeaderboardUserHistory = require("sea.leaderboards.LeaderboardUserHistory")

---@type rdb.ModelOptions
local leaderboard_user_histories = {}

leaderboard_user_histories.metatable = LeaderboardUserHistory

leaderboard_user_histories.relations = table_util.copy(leaderboard_users.relations)

function leaderboard_user_histories.from_db(row)
	---@type sea.LeaderboardUserHistory
	local obj = row

	obj.total_rating = {}
	obj.total_accuracy = {}
	obj.rank = {}

	for i = 1, LeaderboardUserHistory.size do
		obj.total_rating[i] = row["total_rating_" .. i]
		obj.total_accuracy[i] = row["total_accuracy_" .. i]
		obj.rank[i] = row["rank_" .. i]
		row["total_rating_" .. i] = nil
		row["total_accuracy_" .. i] = nil
		row["rank_" .. i] = nil
	end
end

return leaderboard_user_histories
