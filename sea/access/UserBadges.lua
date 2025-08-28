local class = require("class")

---@class sea.UserBadges
---@operator call: sea.UserBadges
local UserBadges = class()

---@param users_repo sea.UsersRepo
function UserBadges:new(users_repo)
	self.users_repo = users_repo
end

---@param user sea.User
---@return sea.UserBadge[]
function UserBadges:getUserBadges(user)
	return self.users_repo:getUserBadges(user.id)
end

return UserBadges
