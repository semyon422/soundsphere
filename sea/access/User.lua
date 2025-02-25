local class = require("class")

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
local User = class()

return User
