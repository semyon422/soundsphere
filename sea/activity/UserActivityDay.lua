local ActivityDate = require("sea.activity.ActivityDate")

---@class sea.UserActivityDay: sea.ActivityDate
---@operator call: sea.UserActivityDay
---@field user_id integer
---@field timezone integer
---@field count integer
local UserActivityDay = ActivityDate + {}

function UserActivityDay:new()
	
end

return UserActivityDay
