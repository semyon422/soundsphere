local class = require("class")

---@class sea.TeamAccess
---@operator call: sea.TeamAccess
local TeamAccess = class()

---@param user sea.User
function TeamAccess:canCreate(user)
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
