local class = require("class")

---@class sea.DifftablesAccess
---@operator call: sea.DifftablesAccess
local DifftablesAccess = class()

---@param user sea.User
---@return boolean
function DifftablesAccess:canManage(user)
	return true
end

return DifftablesAccess
