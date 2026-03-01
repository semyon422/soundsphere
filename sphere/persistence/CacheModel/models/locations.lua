---@class sea.Location
---@field id integer
---@field path string
---@field name string
---@field is_relative boolean
---@field is_internal boolean

local locations = {}

locations.table_name = "locations"

locations.types = {
	is_relative = "boolean",
	is_internal = "boolean",
}

locations.relations = {}

return locations
