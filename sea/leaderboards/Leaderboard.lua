local class = require("class")

---@class sea.Leaderboard
---@operator call: sea.Leaderboard
---@field id integer
---@field name string
---@field description string
---@field owner_community_id integer - ?
---@field created_at integer
---@field rating_calculator integer enum
---@field scores_combiner integer enum
---@field scores_combiner_count integer
---@field communities_combiner integer enum
---@field communities_combiner_count integer
---@field difftables_count integer
---@field users_count integer
---filters
---@field nearest nil|true|false any, enabled, disabled
---@field result "fail"|"pass"|"fc"|"pfc"
---@field allow_custom boolean
---@field allow_const boolean
---@field allow_pause boolean
---@field allow_reorder boolean
---@field allow_modifiers boolean
---@field allow_tap_only boolean
---@field allow_free_timings boolean
---@field mode sea.Gamemode
---@field rate "any"|number[]|{min: number, max: number} any, values, range
---@field ranked_lists integer[]
local Leaderboard = class()

---@param user sea.User
---@return sea.Chartplay[]
function Leaderboard:getBestChartplays(user)
	return {}
end

return Leaderboard
