local class = require("class")

---@class sea.ILeaderboardsRepo
---@operator call: sea.ILeaderboardsRepo
local ILeaderboardsRepo = class()

---@return sea.Leaderboard[]
function ILeaderboardsRepo:getLeaderboards()
	return {}
end

---@param id integer
---@return sea.Leaderboard?
function ILeaderboardsRepo:getLeaderboard(id)
	return {}
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function ILeaderboardsRepo:createLeaderboard(leaderboard)
	return leaderboard
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function ILeaderboardsRepo:updateLeaderboard(leaderboard)
	return leaderboard
end

---@param id integer
---@return sea.Leaderboard?
function ILeaderboardsRepo:deleteLeaderboard(id)
end

return ILeaderboardsRepo
