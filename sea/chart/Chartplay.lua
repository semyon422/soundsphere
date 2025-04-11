local valid = require("valid")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local ChartplayBase = require("sea.chart.ChartplayBase")
local ChartplayComputed = require("sea.chart.ChartplayComputed")
local RateType = require("sea.chart.RateType")
local Gamemode = require("sea.chart.Gamemode")
local Result = require("sea.chart.Result")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class sea.Chartplay: sea.ChartplayBase, sea.ChartplayComputed
---@operator call: sea.Chartplay
--- SERVER defined fields
---@field id integer
---@field user_id integer
---@field compute_state sea.ComputeState
---@field submitted_at integer
---@field computed_at integer
--- CLEINT defined fields
---@field online_id integer
--- REPLAY HASH
---@field replay_hash string
--- REQUIRED for computation: sea.ChartplayBase
--- METADATA not for computation: sea.ChartplayBase
--- COMPUTED: sea.ChartplayComputed
local Chartplay = ChartplayBase + ChartplayComputed

---@param v integer[]
local function is_columns_order(v)
	local t = table.move(v, 1, #v, 1)
	table.sort(t)
	for i = 1, #v do
		if i ~= v[i] then
			return
		end
	end
	return true
end
is_columns_order = valid.optional(valid.compose(valid.array(types.index, 100), is_columns_order))

assert(is_columns_order())
assert(is_columns_order({1, 3, 2}))
assert(not is_columns_order({1, 3}))

---@param chartplay sea.Chartplay
---@return true?
---@return string?
local function subtimings_pair(chartplay)
	local ok, err = TimingValuesFactory:get(chartplay.timings, chartplay.subtimings)
	if not ok then
		return nil, err
	end
	return true
end

local validate_chartplay = valid.struct({
	replay_hash = types.md5hash,
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
--- ChartplayComputed
	result = types.new_enum(Result),
	judges = valid.array(types.count, 10),
	accuracy = types.number,
	max_combo = types.count,
	perfect_count = types.count,
	miss_count = types.count,
	rating = types.number,
	accuracy_osu = types.number,
	accuracy_etterna = types.number,
	rating_pp = types.number,
	rating_msd = types.number,
})

validate_chartplay = valid.compose(validate_chartplay, subtimings_pair)

---@return true?
---@return string|util.Errors?
function Chartplay:validate()
	return validate_chartplay(self)
end

return Chartplay
