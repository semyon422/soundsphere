local class = require("class")

---@class sea.LeaderboardUser
---@operator call: sea.LeaderboardUser
---@field id integer
---@field leaderboard_id integer
---@field user_id integer
---@field scores_count integer
---@field total_rating number
---@field rank integer
---@field updated_at integer
local LeaderboardUser = class()

return LeaderboardUser
