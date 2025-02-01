local class = require("class")
local Leaderboard = require("sea.leaderboards.Leaderboard")

---@class sea.LeaderboardsRepo
---@operator call: sea.LeaderboardsRepo
local LeaderboardsRepo = class()

---@param models rdb.Models
function LeaderboardsRepo:new(models)
	self.models = models
end

---@return sea.Leaderboard[]
function LeaderboardsRepo:getLeaderboards()
	return self.models.leaderboards:select()
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:getLeaderboard(id)
	return self.models.leaderboards:find({id = id})
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:createLeaderboard(leaderboard)
	return self.models.leaderboards:create(leaderboard)
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function LeaderboardsRepo:updateLeaderboard(leaderboard)
	return self.models.leaderboards:update(leaderboard, {id = leaderboard.id})[1]
end

---@param id integer
---@return sea.Leaderboard?
function LeaderboardsRepo:deleteLeaderboard(id)
	return self.models.leaderboards:remove({id = id})[1]
end

return LeaderboardsRepo
