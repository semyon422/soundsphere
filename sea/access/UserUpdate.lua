local class = require("class")

local valid = require("valid")
local types = require("sea.shared.types")

---@class sea.UserUpdate
---@operator call: sea.UserUpdate
---@field id integer
---@field name string?
---@field description string?
---@field activity_timezone sea.Timezone?
---@field enable_gradient boolean?
---@field color_left integer?
---@field color_right integer?
---@field avatar string?
---@field banner string?
---@field discord string?
---@field country_code string?
---@field custom_link string?
local UserUpdate = class()

local validate_user_update = valid.struct({
	id = types.integer,
	name = valid.optional(types.name),
	description = valid.optional(types.description),
	activity_timezone = valid.optional(types.timezone),
	enable_gradient = valid.optional(types.boolean),
	color_left = valid.optional(types.number),
	color_right = valid.optional(types.number),
	avatar = valid.optional(types.string),
	banner = valid.optional(types.string),
	discord = valid.optional(types.string),
	country_code = valid.optional(types.country_code),
	custom_link = valid.optional(types.string),
})

---@return true?
---@return string[]?
function UserUpdate:validate()
	return valid.flatten(validate_user_update(self))
end

return UserUpdate
