local class = require("class")
local Roles = require("sea.access.Roles")

---@class sea.UsersAccess
---@operator call: sea.UsersAccess
local UsersAccess = class()

---@param user sea.User
---@param target_user sea.User
---@param time integer
---@return boolean
function UsersAccess:canUpdate(user, target_user, time)
	local roles = Roles:filter(user.user_roles, time)
	local _roles = Roles:filter(target_user.user_roles, time)
	return Roles:compare(roles, _roles)
end

---@param user sea.User
---@param time integer
---@param role sea.Role
---@return boolean
function UsersAccess:canChangeRole(user, time, role)
	local roles = Roles:filter(user.user_roles, time)
	return Roles:compare(roles, {role})
end

return UsersAccess
