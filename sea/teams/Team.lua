local class = require("class")

---@class sea.Team
---@operator call: sea.Team
---@field id integer
---@field name string
---@field alias string
---@field description string
---@field owner_id integer
---@field type sea.TeamType
---@field users_count integer
---@field created_at integer
local Team = class()

return Team
