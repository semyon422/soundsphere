local Enum = require("rdb.Enum")

---@enum (key) sea.old.Roles
local Roles = {
	creator = 0,
	admin = 1,
	moderator = 2,
	user = 3,
	donator = 4,
}

return Enum(Roles)
