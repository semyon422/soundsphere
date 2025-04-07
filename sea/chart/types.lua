local valid = require("valid")
local types = require("sea.shared.types")

local chart_types = {}

-- TODO: better validation
chart_types.timings_or_healths = valid.struct({
	name = types.name,
	data = valid.optional(types.number),
})

-- TODO: better validation
chart_types.modifier = valid.struct({})

chart_types.modifiers = valid.array(chart_types.modifier, 10)

return chart_types
