local Chartkey = require("sea.chart.Chartkey")

---@class sea.Chartplay: sea.Chartkey
---@operator call: sea.Chartplay
---@field id integer
---@field online_id integer client-only
---@field user_id integer
---@field events_hash string
---@field notes_hash string
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[] modifierset_id?
---@field custom boolean
---@field rate number
---@field rate_type sea.RateType
---@field const boolean
---@field timings sea.Timings
---@field single boolean TODO: replace with "mode"
---@field created_at integer
---@field submitted_at integer
---@field computed_at integer
---@field compute_state sea.ComputeState
---@field ranked_at integer
---@field ranked_state boolean TODO: custom modifiers
---@field pause_count integer
---@field accuracy number
---@field max_combo integer
---@field perfect_count integer
---@field not_perfect_count integer
---@field miss_count integer
---@field rating number
local Chartplay = Chartkey + {}

local computed_keys = {
	"notes_hash",
	"accuracy",
	"max_combo",
	"perfect_count",
	"not_perfect_count",
	"miss_count",
	"rating",
}

---@param values sea.Chartplay
---@return boolean
function Chartplay:equalsComputed(values)
	for _, key in ipairs(computed_keys) do
		if self[key] ~= values[key] then
			return false
		end
	end
	return true
end

return Chartplay
