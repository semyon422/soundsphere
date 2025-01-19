local class = require("class")

---@class sea.ChartfilesAccess
---@operator call: sea.ChartfilesAccess
local ChartfilesAccess = class()

---@param user sea.User
---@return boolean
function ChartfilesAccess:canSubmit(user)
	return true
end

return ChartfilesAccess
