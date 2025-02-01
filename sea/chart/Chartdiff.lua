local Chartkey = require("sea.chart.Chartkey")

---@class sea.Chartdiff: sea.Chartkey
---@operator call: sea.Chartdiff
---@field id integer
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[]
---@field rate number
---@field rate_type sea.RateType
---@field mode sea.Gamemode
---@field notes_hash string
---@field inputmode string
---@field notes_count integer total object count
---@field judges_count integer total number of judgeable QTEs (long note = 2 qte)
---@field note_types_count {[notechart.NoteType]: integer} by type, sum = notes_count
---@field density_data number[] 128 values, 4 bit per value, density of hits
---@field sv_data number[] 128 values, 4 bit per value, (visual duration) / (absoulte duration) ?
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
