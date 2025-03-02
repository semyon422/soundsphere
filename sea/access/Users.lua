local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")

---@class sea.Users
---@operator call: sea.Users
local Users = class()

---@param users_repo sea.IUsersRepo
function Users:new(users_repo)
	self.users_repos = users_repo
	self.users_access = UsersAccess()
end

---@param user sea.User
function Users:register(user)

end

---@param user sea.User
function Users:login(user)

end

---@param user sea.User
function Users:ban(user)

end

---@param user sea.User
function Users:giveRole(user)

end

---@param user sea.User
function Users:takeRole(user)

end

return Users
