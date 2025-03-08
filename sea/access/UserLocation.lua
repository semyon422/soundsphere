local class = require("class")

---@class sea.UserLocation
---@operator call: sea.UserLocation
---@field id integer
---@field user_id integer
---@field ip string
---@field created_at integer
---@field updated_at integer
---@field is_register boolean
---@field sessions_count integer
local UserLocation = class()

return UserLocation
