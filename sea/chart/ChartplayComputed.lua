local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local types = require("sea.shared.types")

---@class sea.ChartplayComputed
---@operator call: sea.ChartplayComputed
--- COMPUTED
---@field judges integer[] computed always using chart's timings/judges
---@field accuracy number normalscore
---@field max_combo integer strictly timing-based
---@field miss_count integer strictly timing-based
---@field not_perfect_count integer sum of all judges except first
---@field pass boolean
---@field rating number enps normalscore 32
---@field rating_pp number
---@field rating_msd number
local ChartplayComputed = class()

function ChartplayComputed:new()
	self.pass = true
	self.judges = {}
	self.accuracy = 0
	self.max_combo = 0
	self.miss_count = 0
	self.not_perfect_count = 0
	self.rating = 0
	self.rating_pp = 0
	self.rating_msd = 0
end

ChartplayComputed.struct = {
	judges = valid.array(types.count, 10),
	accuracy = types.number_or_inf,
	max_combo = types.count,
	miss_count = types.count,
	not_perfect_count = types.count,
	pass = types.boolean,
	rating = types.number,
	rating_pp = types.number,
	rating_msd = types.number,
}

local computed_keys = table_util.keys(ChartplayComputed.struct)

local computed_keys_no_msd = table_util.copy(computed_keys)
table.remove(computed_keys_no_msd, table_util.indexof(computed_keys_no_msd, "rating_msd"))

local validate_chartplay_computed = valid.struct(ChartplayComputed.struct)

---@return true?
---@return string|valid.Errors?
function ChartplayComputed:validate()
	return validate_chartplay_computed(self)
end

---@param values sea.ChartplayComputed
---@param no_msd boolean?
---@return boolean?
---@return string?
function ChartplayComputed:equalsComputed(values, no_msd)
	local keys = computed_keys
	if no_msd then
		keys = computed_keys_no_msd
	end
	return valid.equals(table_util.sub(self, keys), table_util.sub(values, keys))
end

---@param base sea.ChartplayComputed
function ChartplayComputed:importChartplayComputed(base)
	for k in pairs(ChartplayComputed.struct) do
		self[k] = base[k] ---@diagnostic disable-line
	end
end

---@param base sea.ChartplayComputed
function ChartplayComputed:exportChartplayComputed(base)
	for k in pairs(ChartplayComputed.struct) do
		base[k] = self[k] ---@diagnostic disable-line
	end
end

return ChartplayComputed
