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

---@param values sea.Chartplay
---@return boolean
function ChartplayComputed:equalsComputed(values)
	for _, key in ipairs(computed_keys) do
		---@type any, any
		local a, b = self[key], values[key]
		if type(a) == "table" and type(b) == "table" then
			if not table_util.deepequal(a, b) then
				return false
			end
		elseif a ~= b then
			return false
		end
	end
	return true
end

return ChartplayComputed
