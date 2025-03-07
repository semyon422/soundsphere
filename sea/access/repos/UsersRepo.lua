local relations = require("rdb.relations")
local IUsersRepo = require("sea.access.repos.IUsersRepo")

---@class sea.UsersRepo: sea.IUsersRepo
---@operator call: sea.UsersRepo
local UsersRepo = IUsersRepo + {}

---@param models rdb.Models
function UsersRepo:new(models)
	self.models = models
end

---@return sea.User[]
function UsersRepo:getUsers()
	local users = self.models.users:select()
	relations.preload(self.models.users, users, "user_roles")
	return users
end

---@param id integer
---@return sea.User?
function UsersRepo:getUser(id)
	local user = self.models.users:find({id = id})
	relations.preload(self.models.users, {user}, "user_roles")
	return user
end

---@param email string
---@return sea.User?
function UsersRepo:findUserByEmail(email)
	return self.models.users:find({email = email})
end

---@param user sea.User
---@return sea.User
function UsersRepo:createUser(user)
	return self.models.users:create(user)
end

---@param user sea.User
---@return sea.User
function UsersRepo:updateUser(user)
	return self.models.users:update(user, {id = user.id})[1]
end

---@param id integer
---@return sea.User?
function UsersRepo:deleteUser(id)
	return self.models.users:remove({id = id})[1]
end

--------------------------------------------------------------------------------

---@param user_id integer
---@param role sea.Role
---@return sea.UserRole?
function UsersRepo:getUserRole(user_id, role)
	return self.models.user_users:find({
		user_id = assert(user_id),
		role = assert(role),
	})
end

---@param user_role sea.UserRole
---@return sea.UserRole
function UsersRepo:createUserRole(user_role)
	return self.models.user_users:create(user_role)
end

---@param user_role sea.UserRole
---@return sea.UserRole
function UsersRepo:updateUserRole(user_role)
	return self.models.user_users:update(user_role, {id = user_role.id})[1]
end

return UsersRepo
