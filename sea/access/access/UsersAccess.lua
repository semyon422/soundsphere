local class = require("class")
local Roles = require("sea.access.Roles")

---@class sea.UsersAccess
---@operator call: sea.UsersAccess
local UsersAccess = class()

---@param user sea.User
---@param target_user sea.User
---@param time integer
---@return true?
function UsersAccess:canUpdate(user, target_user, time)
	local user_roles = Roles:filterActive(user.user_roles, time)
	local _user_roles = Roles:filterActive(target_user.user_roles, time)
	return Roles:compare(user_roles, _user_roles)
end

return UsersAccess
