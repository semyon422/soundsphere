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
function TeamAccess:canUpdate(user, team)
	return team.owner_id == user.id
end

---@param user sea.User
---@param team sea.Team
function TeamAccess:canJoin(user, team)
	return team.type == "open" or team.type == "request"
end

return TeamAccess
