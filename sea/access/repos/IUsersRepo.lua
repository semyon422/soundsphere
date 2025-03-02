local class = require("class")

---@class sea.IUsersRepo
---@operator call: sea.IUsersRepo
local IUsersRepo = class()

---@return sea.User[]
function IUsersRepo:getUsers()
	return {}
end

---@param id integer
---@return sea.User?
function IUsersRepo:getUser(id)
	return {}
end

---@param user sea.User
---@return sea.User
function IUsersRepo:createUser(user)
	return user
end

---@param user sea.User
---@return sea.User
function IUsersRepo:updateUser(user)
	return user
end

---@param id integer
---@return sea.User?
function IUsersRepo:deleteUser(id)
end

--------------------------------------------------------------------------------

---@param user_id integer
---@param role sea.Role
---@return sea.UserRole?
function IUsersRepo:getUserRole(user_id, role)
	return {}
end

---@param user_role sea.UserRole
---@return sea.UserRole
function IUsersRepo:createUserRole(user_role)
	return {}
end

---@param user_user sea.UserRole
---@return sea.UserRole
function IUsersRepo:updateUserRole(user_user)
	return user_user
end

return IUsersRepo
