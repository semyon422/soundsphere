local class = require("class")

---@class sea.TeamUser
---@operator call: sea.TeamUser
---@field id integer
---@field team_id integer
---@field user_id integer
---@field is_accepted boolean
---@field is_invitation boolean
---@field created_at integer
---@field user sea.User?
local TeamUser = class()

return TeamUser
