local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")

---@class sea.Session
---@operator call: sea.Session
---@field id integer
---@field user_id integer
---@field active boolean
---@field created_at integer
---@field updated_at integer
local Session = class()

Session.struct = {
	id = types.integer,
	user_id = types.integer,
	active = types.boolean,
	created_at = types.integer,
	updated_at = types.integer,
}

local validate_session = valid.struct(Session.struct)

---@return true?
---@return string?
function Session:validate()
	return valid.format(validate_session(self))
end

---@return boolean
function Session:isAnon()
	return not self.id
end

return Session
