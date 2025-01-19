local class = require("class")

---@class sea.Chartplay
---@operator call: sea.Chartplay
---@field id integer
---@field online_id integer client-only
---@field user_id integer
---@field events_hash string
---@field notes_hash string
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[] modifierset_id?
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
---@field accuracy number
---@field max_combo integer
---@field perfect_count integer
---@field not_perfect_count integer
---@field miss_count integer
---@field pause_count integer
---@field rating number
local Chartplay = class()

return Chartplay
