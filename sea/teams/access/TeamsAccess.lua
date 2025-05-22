local class = require("class")

---@class sea.TeamAccess
---@operator call: sea.TeamAccess
local TeamAccess = class()

---@param user sea.User
---@param time integer
---@return boolean
---@return string? error
function TeamAccess:canCreate(user, time)
	if user:isAnon() or not user:hasRole("donator", time) or user.play_time < 60 * 60 * 48 then
		return false, "not allowed"
	end
	return true
end

---@param user sea.User
---@param team sea.Team
---@return boolean
---@return string? error
function TeamAccess:canUpdate(user, team)
	if team.owner_id == user.id then
		return true
	end
	return false, "not allowed"
end

---@param user sea.User
---@param team sea.Team
function TeamAccess:canJoin(user, team)
	return team.type == "open" or team.type == "request"
end

return TeamAccess
