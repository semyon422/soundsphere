local UserActivityDay = require("sea.activity.UserActivityDay")
local Timezone = require("sea.activity.Timezone")

---@type rdb.ModelOptions
local user_activity_days = {}

user_activity_days.metatable = UserActivityDay

user_activity_days.types = {
	timezone = Timezone,
}

return user_activity_days
