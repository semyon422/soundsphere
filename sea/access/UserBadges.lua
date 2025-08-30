local class = require("class")
local UserBadge = require("sea.access.UserBadge")
local UsersAccess = require("sea.access.access.UsersAccess")

---@class sea.UserBadges
---@operator call: sea.UserBadges
local UserBadges = class()

---@param users_repo sea.UsersRepo
function UserBadges:new(users_repo)
	self.users_repo = users_repo
	self.users_access = UsersAccess()
end

---@param user sea.User
---@return sea.UserBadge[]
function UserBadges:getUserBadges(user)
	return self.users_repo:getUserBadges(user.id)
end

---@param user sea.User
---@param target_user_id integer
---@param badge_id string
---@return sea.UserBadge
---@return string err
function UserBadges:createUserBadge(user, target_user_id, badge_id)
	if not UserBadge:encode_safe(badge_id) then
		return nil, ("badge doesn't exist")
	end

	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not found"
	end

	local can, err = self.users_access:canUpdate(user, target_user, time)
	if not can then
		return nil, "not allowed"
	end

	return self.users_repo:createUserBadge(target_user.id, badge_id)
end

---@param user sea.User
---@param target_user_id integer
---@param badge_id string
function UserBadges:deleteUserBadge(user, target_user_id, badge_id)
	local target_user = self.users_repo:getUser(target_user_id)
	if not target_user then
		return nil, "not found"
	end

	local can, err = self.users_access:canUpdate(user, target_user, time)
	if not can then
		return nil, "not allowed"
	end

	return self.users_repo:deleteUserBadge(target_user_id, badge_id)
end

return UserBadges
