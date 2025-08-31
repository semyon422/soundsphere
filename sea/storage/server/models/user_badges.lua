local Badge = require("sea.access.Badge")

---@type rdb.ModelOptions
local user_badges = {}

user_badges.types = {
	badge = Badge,
}

return user_badges
