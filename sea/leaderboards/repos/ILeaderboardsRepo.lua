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

---@param lb sea.Leaderboard
---@param chartplay sea.Chartplay
---@return boolean
function ILeaderboardsRepo:checkChartplay(lb, chartplay)
	return false
end

---@param lb sea.Leaderboard
---@param user_id integer
---@return sea.Chartplay[]
function ILeaderboardsRepo:getBestChartplays(lb, user_id)
	return {}
end

--------------------------------------------------------------------------------

---@param leaderboard_id integer
---@param user_id integer
---@return sea.LeaderboardUser?
function ILeaderboardsRepo:getLeaderboardUser(leaderboard_id, user_id)
	return {}
end

---@param leaderboard_user sea.LeaderboardUser
---@return sea.LeaderboardUser
function ILeaderboardsRepo:createLeaderboardUser(leaderboard_user)
	return {}
end

---@param leaderboard_user sea.LeaderboardUser
---@return sea.LeaderboardUser
function ILeaderboardsRepo:updateLeaderboardUser(leaderboard_user)
	return leaderboard_user
end

return ILeaderboardsRepo
