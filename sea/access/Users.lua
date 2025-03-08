local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")
local User = require("sea.access.User")
local UserLocation = require("sea.access.UserLocation")

---@class sea.Users
---@operator call: sea.Users
local Users = class()

Users.is_register_enabled = true
Users.ip_register_delay = 24 * 60 * 60

---@param users_repo sea.IUsersRepo
---@param password_hasher sea.IPasswordHasher
function Users:new(users_repo, password_hasher)
	self.users_repo = users_repo
	self.password_hasher = password_hasher
	self.users_access = UsersAccess()
end

---@param _ sea.User
---@param user_values sea.User
---@param ip string
---@return sea.User?
---@return string?
function Users:register(_, user_values, ip)
	if not self.is_register_enabled then
		return nil, "registration disabled"
	end

	local user_location = self.users_repo:getRecentRegisterUserLocation(ip)
	if user_location and user_location.created_at + self.ip_register_delay > os.time() then
		return nil, "registration rate exceeded"
	end

	local email = user_values.email:lower()

	local user = self.users_repo:findUserByEmail(email)
	if user then
		return nil, "this email is taken"
	end

	user = self.users_repo:findUserByName(user_values.name)
	if user then
		return nil, "this name is taken"
	end

	local time = os.time()

	user = User()
	user.name = user_values.name
	user.email = email
	user.password = self.password_hasher:digest(user_values.password)
	user.description = ""
	user.latest_activity = time
	user.created_at = time
	user.is_banned = false
	user.chartplays_count = 0
	user.chartmetas_count = 0
	user.chartdiffs_count = 0
	user.chartfiles_upload_size = 0
	user.chartplays_upload_size = 0
	user.play_time = 0

	user = self.users_repo:createUser(user)

	user_location = UserLocation()
	user_location.user_id = user.id
	user_location.ip = ip
	user_location.created_at = time
	user_location.updated_at = time
	user_location.is_register = true
	user_location.sessions_count = 0

	self.users_repo:createUserLocation(user_location)

	return user
end

local login_failed = "Login failed. Invalid email or password"

---@param _ sea.User
---@param email string
---@param password string
function Users:login(_, email, password)
	local user = self.users_repo:findUserByEmail(email)
	if not user then
		return nil, login_failed
	end

	local valid = self.password_hasher:verify(password, user.password)
	if not valid then
		return nil, login_failed
	end

	return user
end

---@param user sea.User
---@param target_user sea.User
function Users:ban(user, target_user)

end

---@param user sea.User
---@param target_user sea.User
function Users:giveRole(user, target_user)

end

---@param user sea.User
---@param target_user sea.User
function Users:takeRole(user, target_user)

end

---@param user sea.User
---@param code string
function Users:oauth(user, code)

end

return Users
