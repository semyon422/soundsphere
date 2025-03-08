local UserLocation = require("sea.access.UserLocation")

---@type rdb.ModelOptions
local user_locations = {}

user_locations.metatable = UserLocation

user_locations.types = {
	is_register = "boolean",
}

return user_locations
