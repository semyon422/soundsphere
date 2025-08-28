local Badges = require("sea.access.Badges")

---@type rdb.ModelOptions
local user_badges = {}

user_badges.types = {
	badge = Badges,
}

return user_badges
