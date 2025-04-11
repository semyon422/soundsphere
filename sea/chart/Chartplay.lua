local valid = require("valid")
local table_util = require("table_util")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local ChartplayBase = require("sea.chart.ChartplayBase")
local ChartplayComputed = require("sea.chart.ChartplayComputed")

---@class sea.Chartplay: sea.ChartplayBase, sea.ChartplayComputed
---@operator call: sea.Chartplay
--- SERVER defined fields
---@field id integer
---@field user_id integer
---@field compute_state sea.ComputeState
---@field submitted_at integer
---@field computed_at integer
---@field created_at integer
--- CLEINT defined fields
---@field online_id integer
--- REPLAY HASH
---@field replay_hash string
--- REQUIRED for computation: sea.ChartplayBase
--- METADATA not for computation: sea.ChartplayBase
--- COMPUTED: sea.ChartplayComputed
local Chartplay = ChartplayBase + ChartplayComputed

Chartplay.struct = {
	replay_hash = types.md5hash,
	created_at = types.time,
}
table_util.copy(ChartplayBase.struct, Chartplay.struct)
table_util.copy(ChartplayComputed.struct, Chartplay.struct)

assert(#table_util.keys(Chartplay.struct) == 28)

local validate_chartplay = valid.compose(valid.struct(Chartplay.struct), chart_types.subtimings_pair)

---@return true?
---@return string|util.Errors?
function Chartplay:validate()
	return validate_chartplay(self)
end

return Chartplay
