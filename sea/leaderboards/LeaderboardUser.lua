local class = require("class")
local erfunc = require("libchart.erfunc")

---@class sea.LeaderboardUser
---@operator call: sea.LeaderboardUser
---@field id integer
---@field leaderboard_id integer
---@field user_id integer
---@field total_rating number
---@field total_accuracy number
---@field rank integer
---@field updated_at integer
local LeaderboardUser = class()

---@return number
function LeaderboardUser:getNormAccuracy()
	return erfunc.erf(0.032 / (self.total_accuracy * math.sqrt(2)))
end

return LeaderboardUser
