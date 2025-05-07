local class = require("class")

---@class sea.IUsersRepo
---@operator call: sea.IUsersRepo
local IUsersRepo = class()

---@return sea.User[]
function IUsersRepo:getUsers()
	return {}
end

---@return sea.UserInsecure[]
function IUsersRepo:getUsersInsecure()
	return {}
end

---@param id integer
---@return sea.User?
function IUsersRepo:getUser(id)
	return {}
end

---@param email string
---@return sea.User?
function IUsersRepo:findUserByEmail(email)
	return {}
end

---@param email string
---@return sea.UserInsecure?
function IUsersRepo:findUserInsecureByEmail(email)
	return {}
end

---@param name string
---@return sea.User?
function IUsersRepo:findUserByName(name)
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
---@return sea.UserRole[]
function IUsersRepo:getUserRoles(user_id)
	return {}
end

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

---@param user_role sea.UserRole
---@return sea.UserRole
function IUsersRepo:updateUserRole(user_role)
	return user_role
end

---@param user_role sea.UserRole
---@return sea.UserRole
function IUsersRepo:deleteUserRole(user_role)
	return user_role
end

--------------------------------------------------------------------------------

---@param user_id integer
---@return sea.Session[]
function IUsersRepo:getSessions(user_id)
	return {}
end

---@param user_id integer
---@return sea.Session[]
function IUsersRepo:getSessionsInsecure(user_id)
	return {}
end

---@param user_id integer
---@return sea.UserLocation[]
function IUsersRepo:getUserLocations(user_id)
	return {}
end

---@param user_id integer
---@param ip string
---@return sea.UserLocation?
function IUsersRepo:getUserLocation(user_id, ip)
	return {}
end

---@param ip string
---@return sea.UserLocation?
function IUsersRepo:getRecentRegisterUserLocation(ip)
	return {}
end

---@param user_location sea.UserLocation
---@return sea.UserLocation?
function IUsersRepo:createUserLocation(user_location)
	return user_location
end

---@param user_location sea.UserLocation
---@return sea.UserLocation?
function IUsersRepo:updateUserLocation(user_location)
	return user_location
end

--------------------------------------------------------------------------------

---@param id integer
---@return sea.Session?
function IUsersRepo:getSession(id)
	return {}
end

---@param id integer
---@return sea.SessionInsecure?
function IUsersRepo:getSessionInsecure(id)
	return {}
end

---@param session sea.Session
---@return sea.Session?
function IUsersRepo:createSession(session)
	return session
end

---@param session sea.Session
---@return sea.Session?
function IUsersRepo:updateSession(session)
	return session
end

return IUsersRepo
