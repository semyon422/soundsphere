local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")
local User = require("sea.access.User")
local UserLocation = require("sea.access.UserLocation")
local Session = require("sea.access.Session")

---@class sea.Users
---@operator call: sea.Users
local Users = class()

Users.is_login_enabled = true
Users.is_register_enabled = true
Users.ip_register_delay = 24 * 60 * 60

---@param users_repo sea.IUsersRepo
---@param password_hasher sea.IPasswordHasher
function Users:new(users_repo, password_hasher)
	self.users_repo = users_repo
	self.password_hasher = password_hasher
	self.users_access = UsersAccess()

	self.anon_user = User()
	self.anon_user.id = 0
end

---@return sea.User[]
function Users:getUsers()
	local users = self.users_repo:getUsers()
	for _, user in ipairs(users) do
		user:hideConfidential()
	end
	return users
end

---@param id integer?
---@return sea.User
function Users:getUser(id)
	local anon_user = self.anon_user
	if not id then
		return anon_user
	end
	local user = self.users_repo:getUser(id)
	if not user then
		return anon_user
	end
	user:hideConfidential()
	return user
end

---@param _ sea.User
---@param ip string
---@param time integer
---@param user_values sea.User
---@return {session: sea.Session, user: sea.User}?
---@return "disabled"|"rate_exceeded"|"email_taken"|"name_taken"?
function Users:register(_, ip, time, user_values)
	if not self.is_register_enabled then
		return nil, "disabled"
	end

	local user_location = self.users_repo:getRecentRegisterUserLocation(ip)
	if user_location and user_location.created_at + self.ip_register_delay > time then
		return nil, "rate_exceeded"
	end

	local email = user_values.email:lower()

	local user = self.users_repo:findUserByEmail(email)
	if user then
		return nil, "email_taken"
	end

	user = self.users_repo:findUserByName(user_values.name)
	if user then
		return nil, "name_taken"
	end

	user = User()
	user.name = user_values.name
	user.email = email
	user.password = self.password_hasher:digest(user_values.password)
	user.latest_activity = time
	user.created_at = time

	user = self.users_repo:createUser(user)

	local session = Session()
	session.user_id = user.id
	session.active = true
	session.ip = ip
	session.created_at = time
	session.updated_at = time

	session = self.users_repo:createSession(session)

	user_location = UserLocation()
	user_location.user_id = user.id
	user_location.ip = ip
	user_location.created_at = time
	user_location.updated_at = time
	user_location.is_register = true
	user_location.sessions_count = 1

	self.users_repo:createUserLocation(user_location)

	return {session = session, user = user}
end

---@param _ sea.User
---@param ip string
---@param time integer
---@param user_values sea.User
---@return {session: sea.Session, user: sea.User}?
---@return "disabled"|"invalid_credentials"?
function Users:login(_, ip, time, user_values)
	if not self.is_login_enabled then
		return nil, "disabled"
	end

	local user = self.users_repo:findUserByEmail(user_values.email)
	if not user then
		return nil, "invalid_credentials"
	end

	local valid = self.password_hasher:verify(user_values.password, user.password)
	if not valid then
		return nil, "invalid_credentials"
	end

	local session = Session()
	session.active = true
	session.created_at = time
	session.user_id = user.id
	session.active = true
	session.ip = ip
	session.created_at = time
	session.updated_at = time

	session = self.users_repo:createSession(session)

	local user_location = self.users_repo:getUserLocation(user.id, ip)
	if not user_location then
		user_location = UserLocation()
		user_location.user_id = user.id
		user_location.ip = ip
		user_location.created_at = time
		user_location.updated_at = time
		user_location.is_register = false
		user_location.sessions_count = 0
		user_location = assert(self.users_repo:createUserLocation(user_location))
	end

	user_location.sessions_count = user_location.sessions_count + 1
	self.users_repo:updateUserLocation(user_location)

	return {session = session, user = user}
end

---@param user sea.User
---@param time integer
---@param target_user_id integer
---@return sea.User?
---@return "not_allowed"|"not_found"?
function Users:ban(user, time, target_user_id)
	if user.id == target_user_id then
		return nil, "not_allowed"
	end

	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not_found"
	end

	local can, err = self.users_access:canUpdate(user, target_user, time)
	if not can then
		return nil, "not_allowed"
	end

	target_user.is_banned = true
	target_user = self.users_repo:updateUser(target_user)

	return target_user
end

---@param id integer
---@return sea.Session?
function Users:getSession(id)
	return self.users_repo:getSession(id)
end

return Users
