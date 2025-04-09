local valid = require("valid")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local Chartkey = require("sea.chart.Chartkey")
local RateType = require("sea.chart.RateType")
local Gamemode = require("sea.chart.Gamemode")
local ComputeState = require("sea.chart.ComputeState")
local Result = require("sea.chart.Result")
local TimingValues = require("sea.chart.TimingValues")

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
---@field subtimings sea.Subtimings
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
	local ok, err = TimingValues():fromTimings(chartplay.timings, chartplay.subtimings)
	if not ok then
		return nil, err
	end
	return true
end

local validate_chartplay = valid.struct({
	-- user_id = types.index,
	events_hash = types.md5hash,
	-- notes_hash = types.md5hash,
	hash = types.md5hash,
	index = types.index,
	modifiers = chart_types.modifiers,
	custom = types.boolean,
	rate = types.number,
	rate_type = types.new_enum(RateType),
	mode = types.new_enum(Gamemode),
	const = types.boolean,
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = chart_types.timings_or_healths,
	subtimings = chart_types.timings_or_healths,
	healths = chart_types.timings_or_healths,
	columns_order = is_columns_order,
	created_at = types.time,
	-- submitted_at = types.time,
	-- computed_at = types.time,
	-- compute_state = types.new_enum(ComputeState),
	pause_count = types.count,
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
