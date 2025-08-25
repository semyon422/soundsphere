local UserBadge = require("sea.access.UserBadge")

---@type rdb.ModelOptions
local user_badges = {}

user_badges.metatable = UserBadge

return user_badges
