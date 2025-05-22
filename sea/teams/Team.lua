local class = require("class")

local TeamType = require("sea.teams.TeamType")

local valid = require("valid")
local types = require("sea.shared.types")

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

---@param v any
---@return boolean?
---@return string?
local function is_alias(v)
	local ok, err = types.name(v)
	if not ok then
		return nil, err
	end
	---@cast v string

	local len = v:len()

	if len == 0 then
		return nil, "too short"
	elseif len > 4 then
		return nil, "too long"
	end

	return true
end

local validate_team = valid.struct({
	name = types.name,
	alias = is_alias,
	description = types.description,
	type = types.new_enum(TeamType),
})

---@return true?
---@return string[]?
function Team:validate()
	return valid.flatten(validate_team(self))
end

return Team
