local class = require("class")

local valid = require("valid")
local types = require("sea.shared.types")

---@class sea.UserUpdate
---@operator call: sea.UserUpdate
---@field id integer
---@field name string
---@field description string
---@field color_left integer
---@field color_right integer
---@field banner string
---@field discord string
---@field custom_link string
local UserUpdate = class()

local validate_user_update = valid.struct({
	id = types.integer,
	name = valid.optional(types.name),
	description = valid.optional(types.description),
	color_left = valid.optional(types.number),
	color_right = valid.optional(types.number),
	banner = valid.optional(types.string),
	discord = valid.optional(types.string),
	custom_link = valid.optional(types.string),
})

---@return true?
---@return string[]?
function UserUpdate:validate()
	local ok, errs = validate_user_update(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return UserUpdate
