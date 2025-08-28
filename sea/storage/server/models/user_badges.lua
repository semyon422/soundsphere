local UserBadge = require("sea.access.UserBadge")

---@type rdb.ModelOptions
local user_badges = {}

user_badges.types = {
	badge = UserBadge,
}

return user_badges
