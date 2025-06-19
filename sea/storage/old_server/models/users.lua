---@class sea.old.User
---@field id integer
---@field name string
---@field email string
---@field password string
---@field latest_activity integer
---@field latest_score_submitted_at integer
---@field created_at integer
---@field is_banned boolean
---@field is_restricted_info boolean
---@field description string
---@field scores_count integer
---@field notecharts_count integer
---@field notes_count integer
---@field notecharts_upload_size integer
---@field replays_upload_size integer
---@field play_time integer
---@field color_left integer
---@field color_right integer
---@field banner string
---@field discord string
---@field twitter string
---@field custom_link string

---@type rdb.ModelOptions
local users = {}

users.types = {
	is_banned = "boolean",
	is_restricted_info = "boolean",
}

users.relations = {
	user_roles = {has_many = "user_roles", key = "user_id"},
}

return users
