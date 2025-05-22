local class = require("class")

---@class sea.LeaderboardsAccess
---@operator call: sea.LeaderboardsAccess
local LeaderboardsAccess = class()

---@param user sea.User
---@param time integer
---@return boolean?
---@return string?
function LeaderboardsAccess:canManage(user, time)
	if not user:hasRole("admin", time) then
		return nil, "not allowed"
	end
	return true
end

return LeaderboardsAccess
