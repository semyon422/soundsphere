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

local function is_alias(v)
	local success, err = types.name(v)

	if not success then
		return nil, err
	end

	local len = v:len()

	if len == 0 then
		return nil, "too short"
	elseif len > 4 then
		return nil, "too long"
	end

	return true
end

local validate_team = valid.struct({
	id = types.integer,
	name = types.name,
	alias = is_alias,
	description = types.description,
	owner_id = types.integer,
	type = types.new_enum(TeamType),
	users_count = types.integer,
	created_at = types.time,
})

---@return true?
---@return string[]?
function Team:validate()
	local ok, errs = validate_team(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return Team
