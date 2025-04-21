local valid = require("valid")
local table_util = require("table_util")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ChartplayBase = require("sea.chart.ChartplayBase")
local ChartplayComputed = require("sea.chart.ChartplayComputed")

---@class sea.Chartplay: sea.ChartmetaKey, sea.ChartplayBase, sea.ChartplayComputed
---@operator call: sea.Chartplay
--- SERVER defined fields
---@field id integer
---@field user_id integer
---@field compute_state sea.ComputeState
---@field submitted_at integer
---@field computed_at integer
--- CLEINT defined fields
---@field online_id integer
--- METADATA
---@field replay_hash string
---@field pause_count integer
---@field created_at integer client-defined value
--- REQUIRED for computation: sea.ChartplayBase
--- METADATA not for computation: sea.ChartplayBase
--- COMPUTED: sea.ChartplayComputed
local Chartplay = ChartmetaKey + ChartplayBase + ChartplayComputed

Chartplay.struct = {
	replay_hash = types.md5hash,
	pause_count = types.count,
	created_at = types.time,
}
table_util.copy(ChartmetaKey.struct, Chartplay.struct)
table_util.copy(ChartplayBase.struct, Chartplay.struct)
table_util.copy(ChartplayComputed.struct, Chartplay.struct)

assert(#table_util.keys(Chartplay.struct) == 26)

local validate_chartplay = valid.compose(valid.struct(Chartplay.struct), chart_types.subtimings_pair)

---@return true?
---@return string|util.Errors?
function Chartplay:validate()
	return validate_chartplay(self)
end

local keys = table_util.keys(Chartplay.struct)

---@param values sea.Chartplay
---@return boolean
function Chartplay:equalsChartplay(values)
	return table_util.subequal(self, values, keys, table_util.equal)
end

return Chartplay
