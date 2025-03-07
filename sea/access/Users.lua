local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")
local User = require("sea.access.User")

---@class sea.Users
---@operator call: sea.Users
local Users = class()

---@param users_repo sea.IUsersRepo
---@param password_hasher sea.IPasswordHasher
function Users:new(users_repo, password_hasher)
	self.users_repo = users_repo
	self.password_hasher = password_hasher
	self.users_access = UsersAccess()
end

---@param _ sea.User
---@param email string
---@param password string
function Users:register(_, email, password)
	local user = self.users_repo:findUserByEmail(email)
	if user then
		return nil, "This email is already taken"
	end

	user = User()
	user.email = email
	user.password = self.password_hasher:digest(password)
	user.created_at = os.time()

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
