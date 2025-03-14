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
	self.description = ""
	self.is_banned = false
	self.chartplays_count = 0
	self.chartmetas_count = 0
	self.chartdiffs_count = 0
	self.chartfiles_upload_size = 0
	self.chartplays_upload_size = 0
	self.play_time = 0

	self.user_roles = {}
end

---@param role sea.Role
---@param time integer
---@param exact boolean?
---@return boolean
function User:hasRole(role, time, exact)
	local roles = Roles:filter(self.user_roles or {}, time)
	return Roles:hasRole(roles, role, exact)
end

function User:hideConfidential()
	self.email = nil
	self.password = nil
end

return User
