local valid = require("valid")
local types = require("sea.shared.types")

local chart_types = {}

-- TODO: better validation
chart_types.timings_or_healths = valid.struct({
	name = types.name,
	data = valid.optional(types.number),
})

local function modifier_value(v)
	if v == nil then
		return true
	end

	local t = type(v)
	if t == "number" then
		return true
	end

	if t ~= "string" then
		return
	end
	---@cast v string

	return #v <= 127
end

-- TODO: better validation
chart_types.modifier = valid.struct({
	id = types.integer,
	version = types.integer,
	value = modifier_value,
})

chart_types.modifiers = valid.array(chart_types.modifier, 10)

return chart_types
