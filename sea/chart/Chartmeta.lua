local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local BeatmapStatus = require("sea.osu.BeatmapStatus")

---@class sea.Chartmeta
---@operator call: sea.Chartmeta
---@field id integer
---@field hash string
---@field index integer
---@field timings sea.Timings
---@field healths sea.Healths
---@field title string
---@field title_unicode string
---@field artist string
---@field artist_unicode string
---@field name string
---@field creator string
---@field level number
---@field inputmode string
---@field source string
---@field tags string
---@field format string
---@field audio_path string
---@field background_path string
---@field preview_time number
---@field osu_beatmap_id integer
---@field osu_beatmapset_id integer
---@field osu_od number
---@field osu_hp number
---@field osu_ranked_status integer
---@field tempo number
---@field played_at integer
---@field added_at integer
---@field created_at integer
---@field plays_count integer
---@field comment string
local Chartmeta = class()

local computed_keys = {
	"hash",
	"index",
	"timings",
	"healths",
	"title",
	"title_unicode",
	"artist",
	"artist_unicode",
	"name",
	"creator",
	"level",
	"inputmode",
	"source",
	"tags",
	"format",
	"audio_path",
	"background_path",
	"preview_time",
	"tempo",
	"tempo_avg",
	"tempo_max",
	"tempo_min",
}

---@param values sea.Chartdiff
---@return boolean
function Chartmeta:equalsComputed(values)
	for _, key in ipairs(computed_keys) do
		if self[key] ~= values[key] then
			return false
		end
	end
	return true
end

local text = types.description

local validate_chartmeta = valid.struct({
	hash = types.md5hash,
	index = types.index,
	timings = chart_types.timings_or_healths,
	healths = chart_types.timings_or_healths,
	title = text,
	title_unicode = valid.optional(text),
	artist = text,
	artist_unicode = valid.optional(text),
	name = text,
	creator = text,
	level = valid.optional(types.number),
	inputmode = types.name,
	source = valid.optional(text),
	tags = valid.optional(text),
	format = types.name,
	audio_path = valid.optional(text),
	background_path = valid.optional(text),
	preview_time = valid.optional(types.number),
	osu_beatmap_id = valid.optional(types.integer),
	osu_beatmapset_id = valid.optional(types.integer),
	-- osu_od = types.number,
	-- osu_hp = types.number,
	-- osu_ranked_status = types.new_enum(BeatmapStatus),
	tempo = types.number,
	tempo_avg = valid.optional(types.number),
	tempo_max = valid.optional(types.number),
	tempo_min = valid.optional(types.number),
	-- played_at = types.time,
	-- added_at = types.time,
	-- created_at = types.time,
	-- plays_count = types.count,
	-- comment = text,
})

---@return true?
---@return string[]?
function Chartmeta:validate()
	local ok, errs = validate_chartmeta(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return Chartmeta
