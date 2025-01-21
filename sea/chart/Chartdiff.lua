local Chartkey = require("sea.chart.Chartkey")

---@class sea.Chartdiff: sea.Chartkey
---@operator call: sea.Chartdiff
---@field id integer
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[]
---@field rate number
---@field rate_type sea.RateType
---@field notes_hash string
---@field inputmode string
---@field notes_count integer
---@field long_notes_count integer
---@field density_data string
---@field sv_data string
---@field enps_diff number
---@field osu_diff number
---@field msd_diff number
---@field msd_diff_data string
---@field user_diff number
---@field user_diff_data string
local Chartdiff = Chartkey + {}

function Chartdiff:new()
	self.modifiers = {}
end

local computed_keys = {
	"notes_hash",
	"inputmode",
	"notes_count",
	"long_notes_count",
	"density_data",
	"sv_data",
	"enps_diff",
	"osu_diff",
	"msd_diff",
	"msd_diff_data",
	"user_diff",
	"user_diff_data",
}

---@param values sea.Chartdiff
---@return boolean
function Chartdiff:equalsComputed(values)
	for _, key in ipairs(computed_keys) do
		if self[key] ~= values[key] then
			return false
		end
	end
	return true
end

return Chartdiff
