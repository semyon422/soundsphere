local class = require("class")
local UserRole = require("sea.access.UserRole")
local UsersAccess = require("sea.access.access.UsersAccess")

---@class sea.UserRoles
---@operator call: sea.UserRoles
local UserRoles = class()

---@param users_repo sea.UsersRepo
function UserRoles:new(users_repo)
	self.users_repo = users_repo
	self.users_access = UsersAccess()
end

---@param user sea.User
---@param time integer
---@param target_user_id integer
---@param role sea.Role
---@return sea.UserRole?
---@return "not_found"|"not_allowed"|"found"?
function UserRoles:createRole(user, time, target_user_id, role)
	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not_found"
	end

	local can, err = self.users_access:canChangeRole(user, time, role)
	if not can then
		return nil, "not_allowed"
	end

	local user_role = self.users_repo:getUserRole(target_user_id, role)
	if user_role then
		return nil, "found"
	end

	user_role = UserRole(role, time)
	user_role.user_id = user.id
	user_role = self.users_repo:createUserRole(user_role)

	return user_role
end

---@param user sea.User
---@param time integer
---@param target_user_id integer
---@param role sea.Role
---@return sea.UserRole?
---@return "not_found"|"not_allowed"?
function UserRoles:deleteRole(user, time, target_user_id, role)
	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not_found"
	end

	local can, err = self.users_access:canChangeRole(user, time, role)
	if not can then
		return nil, "not_allowed"
	end

	local user_role = self.users_repo:getUserRole(target_user_id, role)
	if not user_role then
		return nil, "not_found"
	end

	self.users_repo:deleteUserRole(user_role)

	return user_role
end

---@param user sea.User
---@param time integer
---@param target_user_id integer
---@param role sea.Role
---@param duration integer
---@return sea.UserRole?
---@return "not_found"|"not_allowed"?
function UserRoles:addTimeRole(user, time, target_user_id, role, duration)
	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not_found"
	end

	local can, err = self.users_access:canChangeRole(user, time, role)
	if not can then
		return nil, "not_allowed"
	end

	local user_role = self.users_repo:getUserRole(target_user_id, role)
	if not user_role then
		return nil, "not_found"
	end

	user_role:addTime(duration, time)
	user_role = self.users_repo:updateUserRole(user_role)

	return user_role
end

---@param user sea.User
---@param time integer
---@param target_user_id integer
---@param role sea.Role
---@return sea.UserRole?
---@return "not_found"|"not_allowed"?
function UserRoles:makeUnexpirableRole(user, time, target_user_id, role)
	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not_found"
	end

	local can, err = self.users_access:canChangeRole(user, time, role)
	if not can then
		return nil, "not_allowed"
	end

	local user_role = self.users_repo:getUserRole(target_user_id, role)
	if not user_role then
		return nil, "not_found"
	end

	user_role:makeUnexpirable(time)
	user_role = self.users_repo:updateUserRole(user_role)

	return user_role
end

return UserRoles
