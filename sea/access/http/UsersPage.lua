local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")

---@class sea.UsersPage
---@operator call: sea.UsersPage
local UsersPage = class()

UsersPage.view = {layout = "users"}

---@param user sea.User
---@param time integer
function UsersPage:new(user, time)
	self.user = user
	self.time = time
	self.users_access = UsersAccess()
end

---@param role sea.Role
---@return boolean
function UsersPage:canChangeRole(role)
	return self.users_access:canChangeRole(self.user, self.time, role)
end

return UsersPage
