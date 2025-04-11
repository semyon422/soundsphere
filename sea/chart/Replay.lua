local valid = require("valid")
local ChartplayBase = require("sea.chart.ChartplayBase")
local json = require("json")
local ReplayNanoChart = require("sphere.models.ReplayModel.ReplayNanoChart")
-- local ReplayConverter = require("sphere.models.ReplayModel.ReplayConverter")
local TimingsDefiner = require("sea.timings.TimingsDefiner")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")

---@class sea.Replay: sea.ChartplayBase
---@operator call: sea.Replay
---@field timing_values sea.TimingValues for backward compatibility
---@field events string encoded
---@field created_at integer
local Replay = ChartplayBase + {}

local validate_replay = valid.struct({
--- ChartplayBase
	-- Chartkey
	hash = types.md5hash,
	index = types.index,
	modifiers = chart_types.modifiers,
	rate = types.number,
	mode = types.new_enum(Gamemode),
	-- Other
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = chart_types.timings,
	subtimings = chart_types.subtimings,
	healths = chart_types.healths,
	columns_order = is_columns_order,
	-- METADATA
	custom = types.boolean,
	const = types.boolean,
	pause_count = types.count,
	created_at = types.time,
	rate_type = types.new_enum(RateType),
})

---@return true?
---@return string|util.Errors?
function Replay:validate()
	return true
end

---@param s string
---@return sea.Replay?
---@return string?
function Replay.decode(s)
	return Replay()
end

---@param replay sea.Replay
---@return string
function Replay.encode(replay)
	return ""
end

return Replay
