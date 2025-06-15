local class = require("class")
local time_util = require("time_util")

---@class sea.LeaderboardUserHistory
---@operator call: sea.LeaderboardUserHistory
---@field id integer
---@field leaderboard_id integer
---@field user_id integer
---@field total_rating number[]
---@field total_accuracy number[]
---@field rank integer[]
---@field updated_at integer
local LeaderboardUserHistory = class()

LeaderboardUserHistory.size = 90

---@param index integer
---@param time integer?
function LeaderboardUserHistory:getIndex(index, time)
	local day = time_util.unix_day(time or self.updated_at)
	return (day - index) % self.size + 1
end

---@param index integer
---@return integer
function LeaderboardUserHistory:getRank(index)
	return self.rank[self:getIndex(index)]
end

---@param index integer
---@return number
function LeaderboardUserHistory:getRating(index)
	return self.total_rating[self:getIndex(index)]
end

---@param index integer
---@return number
function LeaderboardUserHistory:getAccuracy(index)
	return self.total_accuracy[self:getIndex(index)]
end

---@return integer[]
function LeaderboardUserHistory:getRanks()
	---@type integer[]
	local ranks = {}
	for i = 1, self.size do
		ranks[i] = self:getRank(i)
	end
	return ranks
end

---@return number[]
function LeaderboardUserHistory:getRatings()
	---@type integer[]
	local ratings = {}
	for i = 1, self.size do
		ratings[i] = self:getRating(i)
	end
	return ratings
end

return LeaderboardUserHistory
