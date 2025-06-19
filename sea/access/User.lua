local class = require("class")
local Roles = require("sea.access.Roles")
local Timezone = require("sea.activity.Timezone")

---@class sea.User
---@operator call: sea.User
---@field id integer
---@field name string
---@field latest_activity integer
---@field activity_timezone sea.Timezone
---@field created_at integer
---@field is_banned boolean
---@field is_restricted_info boolean
---@field description string
---@field chartplays_count integer
---@field chartmetas_count integer
---@field chartdiffs_count integer
---@field chartfiles_upload_size integer
---@field chartplays_upload_size integer
---@field play_time integer
---@field enable_gradient boolean
---@field color_left integer
---@field color_right integer
---@field avatar string
---@field banner string
---@field discord string
---@field country_code string
---@field custom_link string
---relations
---@field user_roles sea.UserRole[]
local User = class()

function User:new()
	self.activity_timezone = Timezone()
	self.description = ""
	self.is_banned = false
	self.is_restricted_info = false
	self.chartplays_count = 0
	self.chartmetas_count = 0
	self.chartdiffs_count = 0
	self.chartfiles_upload_size = 0
	self.chartplays_upload_size = 0
	self.play_time = 0
	self.enable_gradient = false
	self.color_left = 7128983
	self.color_right = 4376023
	self.avatar = ""
	self.banner = ""
	self.discord = ""
	self.country_code = "xd"
	self.custom_link = ""

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

---@return boolean
function User:isAnon()
	return not self.id
end

return User
