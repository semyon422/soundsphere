local Badge = require("sea.access.Badge")
local UserBadge = require("sea.access.UserBadge")

---@type rdb.ModelOptions
local user_badges = {}

user_badges.metatable = UserBadge

user_badges.types = {
	badge = Badge,
}

return user_badges
