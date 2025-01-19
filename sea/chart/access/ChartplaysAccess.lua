local class = require("class")

---@class sea.ChartplaysAccess
---@operator call: sea.ChartplaysAccess
local ChartplaysAccess = class()

---@param user sea.User
---@return boolean
function ChartplaysAccess:canSubmit(user)
	return true
end

return ChartplaysAccess
