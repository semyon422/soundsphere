local table_util = require("table_util")
local leaderboard_users = require("sea.storage.server.models.leaderboard_users")

---@type rdb.ModelOptions
local leaderboard_users_ranked = table_util.copy(leaderboard_users)

leaderboard_users_ranked.subquery = [[
SELECT
ROW_NUMBER() OVER (PARTITION BY leaderboard_id ORDER BY total_rating DESC) row_number,
leaderboard_users.*
FROM leaderboard_users
]]

return leaderboard_users_ranked
