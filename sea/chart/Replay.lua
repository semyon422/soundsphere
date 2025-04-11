local valid = require("valid")
local table_util = require("table_util")
local ChartplayBase = require("sea.chart.ChartplayBase")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")

---@class sea.Replay: sea.ChartplayBase
---@operator call: sea.Replay
---@field version integer
---@field timing_values sea.TimingValues for backward compatibility
---@field events string encoded
---@field created_at integer
local Replay = ChartplayBase + {}

Replay.struct = {
	version = types.integer,
	timing_values = chart_types.timing_values,
	events = types.binary,
	created_at = types.time,
}
table_util.copy(ChartplayBase.struct, Replay.struct)

assert(#table_util.keys(Replay.struct) == 19)

local validate_replay = valid.struct(Replay.struct)

---@return true?
---@return string|util.Errors?
function Replay:validate()
	return validate_replay(self)
end

return Replay
