local class = require("class")
local UsersAccess = require("sea.access.access.UsersAccess")

---@class sea.UserSettingsPage
---@operator call: sea.UserSettingsPage
local UserSettingsPage = class()

---@param session_user sea.User
---@param target_user sea.User
function UserSettingsPage:new(session_user, target_user)
	self.session_user = session_user
	self.target_user = target_user
	self.users_access = UsersAccess()
end

---@return boolean
function UserSettingsPage:canUpdate()
	return self.users_access:canUpdateSelf(self.session_user, self.target_user, os.time())
end

---@return boolean
function UserSettingsPage:canUpdateNameGradient()
	return self.users_access:canUpdateNameGradient(self.session_user, self.target_user, os.time())
end

---@return boolean
function UserSettingsPage:canBan()
	return self.users_access:canUpdate(self.session_user, self.target_user, os.time())
end

---@return boolean
function UserSettingsPage:canSeeAdminTools()
	return self.users_access:isStaff(self.session_user, os.time())
end

return UserSettingsPage
