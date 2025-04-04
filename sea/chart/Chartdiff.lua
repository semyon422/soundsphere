local Chartkey = require("sea.chart.Chartkey")
local RateType = require("sea.chart.RateType")
local Gamemode = require("sea.chart.Gamemode")
local valid = require("valid")
local types = require("sea.shared.types")

---@class sea.Chartdiff: sea.Chartkey
---@operator call: sea.Chartdiff
---@field id integer
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[]
---@field rate number
---@field rate_type sea.RateType
---@field mode sea.Gamemode
---@field custom_user_id integer
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

local is_modifier = valid.struct({})

local note_types_count = valid.struct({})

local validate_chartdiff = valid.struct({
	hash = types.md5hash,
	index = types.index,
	modifiers = valid.array(is_modifier, 10),
	rate = types.number,
	rate_type = types.new_enum(RateType),
	mode = types.new_enum(Gamemode),
	-- notes_hash = types.md5hash,
	inputmode = types.name,
	notes_count = types.count,
	judges_count = types.count,
	note_types_count = note_types_count,
	density_data = valid.array(types.normalized, 128),
	sv_data = valid.array(types.normalized, 128),
	enps_diff = types.number,
	osu_diff = types.number,
	msd_diff = types.number,
	msd_diff_data = types.binary,
	user_diff = types.number,
	user_diff_data = types.binary,
})

---@return true?
---@return string[]?
function Chartdiff:validate()
	local ok, errs = validate_chartdiff(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return Chartdiff
