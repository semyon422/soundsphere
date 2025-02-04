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
---@field modifiers sea.Modifier[]
---@field custom boolean
---@field rate number
---@field rate_type sea.RateType
---@field mode sea.Gamemode
---@field const boolean
---@field nearest boolean
---@field tap_only boolean - like NoLongNote
---@field timings sea.Timings
---@field healths sea.Healths
---@field columns_order integer[]? nil - unchanged
---@field created_at integer
---@field submitted_at integer
---@field computed_at integer
---@field compute_state sea.ComputeState
---@field pause_count integer
---@field result sea.Result
---@field judges integer[] computed always using chart's timings/judges
---@field accuracy number normalscore
---@field max_combo integer strictly timing-based
---@field perfect_count integer - [-0.016, 0.016] window hits
---@field miss_count integer strictly timing-based
---@field rating number enps normalscore 32
---@field accuracy_osu number
---@field accuracy_etterna number
---@field rating_pp number
---@field rating_msd number
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
