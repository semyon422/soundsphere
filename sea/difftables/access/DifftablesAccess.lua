local class = require("class")

---@class sea.DifftablesAccess
---@operator call: sea.DifftablesAccess
local DifftablesAccess = class()

---@param user sea.User
---@param time integer
---@return boolean
function DifftablesAccess:canManage(user, time)
	return user:hasRole("admin", time)
end

return DifftablesAccess
