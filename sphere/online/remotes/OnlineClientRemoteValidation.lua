local class = require("class")

---@class sea.OnlineClientRemoteValidation
---@operator call: sea.OnlineClientRemoteValidation
local OnlineClientRemoteValidation = class()

---@param remote sphere.OnlineClientRemote
function OnlineClientRemoteValidation:new(remote)
	self.remote = remote
end

---@param user sea.User?
function OnlineClientRemoteValidation:setUser(user)
	self.remote:setUser(user)
end

---@param leaderboards sea.Leaderboard[]
function OnlineClientRemoteValidation:setLeaderboards(leaderboards)
	self.remote:setLeaderboards(leaderboards)
end

---@param leaderboards_users sea.LeaderboardUser[]
function OnlineClientRemoteValidation:setLeaderboardUsers(leaderboards_users)
	self.remote:setLeaderboardUsers(leaderboards_users)
end

return OnlineClientRemoteValidation
