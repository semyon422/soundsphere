local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sea.UsersRepo
---@operator call: sea.UsersRepo
local UsersRepo = class()

---@param models rdb.Models
function UsersRepo:new(models)
	self.models = models
end

---@param order string?
---@return sea.User[]
function UsersRepo:getUsers(order)
	---@type rdb.Options
	local options = {}
	if order then
		options.order = {sql_util.escape_identifier(order) .. " DESC"}
	end
	local users = self.models.users:select(nil, options)
	self.models.users:preload(users, "user_roles")
	return users
end

---@return integer
function UsersRepo:getUsersCount()
	return self.models.users:count()
end

---@return sea.UserInsecure[]
function UsersRepo:getUsersInsecure()
	local users = self.models.users_insecure:select()
	self.models.users:preload(users, "user_roles")
	return users
end

---@param id integer
---@return sea.User?
function UsersRepo:getUser(id)
	local user = self.models.users:find({id = assert(id)})
	self.models.users:preload({user}, "user_roles")
	return user
end

---@param email string
---@return sea.User?
function UsersRepo:findUserByEmail(email)
	return self.models.users:find({email = assert(email)})
end

---@param email string
---@return sea.UserInsecure?
function UsersRepo:findUserInsecureByEmail(email)
	return self.models.users_insecure:find({email = assert(email)})
end

---@param name string
---@return sea.User?
function UsersRepo:findUserByName(name)
	return self.models.users:find({name = assert(name)})
end

---@param user sea.User
---@return sea.User
function UsersRepo:createUser(user)
	return self.models.users:create(user)
end

---@param user sea.User | sea.UserUpdate
---@return sea.User
function UsersRepo:updateUser(user)
	return self.models.users:update(user, {id = assert(user.id)})[1]
end

---@param id integer
---@return sea.User?
function UsersRepo:deleteUser(id)
	return self.models.users:delete({id = assert(id)})[1]
end

--------------------------------------------------------------------------------

---@param user_id integer
---@return sea.UserRole[]
function UsersRepo:getUserRoles(user_id)
	return self.models.user_roles:select({
		user_id = assert(user_id),
	})
end

---@param user_id integer
---@param role sea.Role
---@return sea.UserRole?
function UsersRepo:getUserRole(user_id, role)
	return self.models.user_roles:find({
		user_id = assert(user_id),
		role = assert(role),
	})
end

---@param user_role sea.UserRole
---@return sea.UserRole
function UsersRepo:createUserRole(user_role)
	return self.models.user_roles:create(user_role)
end

---@param user_role sea.UserRole
---@return sea.UserRole
function UsersRepo:updateUserRole(user_role)
	return self.models.user_roles:update(user_role, {id = assert(user_role.id)})[1]
end

---@param user_role sea.UserRole
---@return sea.UserRole
function UsersRepo:deleteUserRole(user_role)
	return self.models.user_roles:delete({id = assert(user_role.id)})
end

--------------------------------------------------------------------------------

---@param user_id integer
---@return sea.UserLocation[]
function UsersRepo:getUserLocations(user_id)
	return self.models.user_locations:select({
		user_id = assert(user_id),
	})
end

---@param user_id integer
---@param ip string
---@return sea.UserLocation?
function UsersRepo:getUserLocation(user_id, ip)
	return self.models.user_locations:find({
		user_id = assert(user_id),
		ip = assert(ip),
	})
end

---@param ip string
---@return sea.UserLocation?
function UsersRepo:getRecentRegisterUserLocation(ip)
	return self.models.user_locations:find({
		ip = assert(ip),
		is_register = true,
	}, {order = {"created_at DESC"}})
end

---@param user_location sea.UserLocation
---@return sea.UserLocation?
function UsersRepo:createUserLocation(user_location)
	return self.models.user_locations:create(user_location)
end

---@param user_location sea.UserLocation
---@return sea.UserLocation?
function UsersRepo:updateUserLocation(user_location)
	return self.models.user_locations:update(user_location, {id = assert(user_location.id)})[1]
end

--------------------------------------------------------------------------------

---@param user_id integer
---@return sea.Session[]
function UsersRepo:getSessions(user_id)
	return self.models.sessions:select({user_id = assert(user_id)})
end

---@param user_id integer
---@return sea.Session[]
function UsersRepo:getSessionsInsecure(user_id)
	return self.models.sessions_insecure:select({user_id = assert(user_id)})
end

---@param id integer
---@return sea.Session?
function UsersRepo:getSession(id)
	return self.models.sessions:find({id = assert(id)})
end

---@param id integer
---@return sea.SessionInsecure?
function UsersRepo:getSessionInsecure(id)
	return self.models.sessions_insecure:find({id = assert(id)})
end

---@param session sea.Session
---@return sea.Session?
function UsersRepo:createSession(session)
	return self.models.sessions:create(session)
end

---@param session sea.Session
---@return sea.Session?
function UsersRepo:updateSession(session)
	return self.models.sessions:update(session, {id = assert(session.id)})[1]
end

return UsersRepo
