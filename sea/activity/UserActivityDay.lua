local class = require("class")

---@class sea.UserActivityDay
---@operator call: sea.UserActivityDay
---@field user_id integer
---@field timezone integer
---@field year integer
---@field month integer
---@field day integer
---@field count integer
local UserActivityDay = class()

function UserActivityDay:new()
	
end

return UserActivityDay
