local class = require("class")
local table_util = require("table_util")

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

local computed_keys = {
	"result",
	"judges",
	"accuracy",
	"max_combo",
	"perfect_count",
	"miss_count",
	"rating",
	"accuracy_osu",
	"accuracy_etterna",
	"rating_pp",
	"rating_msd",
}

---@param values sea.ChartplayComputed
---@return boolean
function ChartplayComputed:equalsComputed(values)
	return table_util.subequal(self, values, computed_keys, table_util.equal)
end

return ChartplayComputed
