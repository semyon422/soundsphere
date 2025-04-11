local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local Result = require("sea.chart.Result")
local types = require("sea.shared.types")

---@class sea.ChartplayComputed
---@operator call: sea.ChartplayComputed
--- COMPUTED
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
local ChartplayComputed = class()

ChartplayComputed.struct = {
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
}

local computed_keys = table_util.keys(ChartplayComputed.struct)

---@param values sea.ChartplayComputed
---@return boolean
function ChartplayComputed:equalsComputed(values)
	return table_util.subequal(self, values, computed_keys, table_util.equal)
end

return ChartplayComputed
