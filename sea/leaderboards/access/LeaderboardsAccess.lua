local class = require("class")

---@class sea.LeaderboardsAccess
---@operator call: sea.LeaderboardsAccess
local LeaderboardsAccess = class()

---@param user sea.User
---@return boolean
function LeaderboardsAccess:canManage(user)
	return true
end

return LeaderboardsAccess
