local class = require("class")
local Roles = require("sea.access.Roles")

---@class sea.User
---@operator call: sea.User
---@field id integer
---@field name string
---@field email string
---@field password string
---@field latest_activity integer
---@field created_at integer
---@field is_banned boolean
---@field description string
---@field chartplays_count integer
---@field chartmetas_count integer
---@field chartdiffs_count integer
---@field chartfiles_upload_size integer
---@field chartplays_upload_size integer
---@field play_time integer
---@field color_left integer
---@field color_right integer
---@field banner string
---@field discord string
---@field custom_link string
---relations
---@field user_roles sea.UserRole[]
local User = class()

function User:new()
	self.user_roles = {}
end

---@param role sea.Role
---@param exact boolean?
---@return boolean
function User:hasRole(role, exact)
	return Roles:hasRole(self.user_roles or {}, role, exact)
end

return User
