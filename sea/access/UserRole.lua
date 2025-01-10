local class = require("class")

---@class sea.UserRole
---@operator call: sea.UserRole
---@field user_id integer
---@field role sea.Role
---@field expires_at integer
---@field total_time integer
local UserRole = class()

return UserRole
