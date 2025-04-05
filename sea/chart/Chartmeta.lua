local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
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
---@field duration number
---@field has_video boolean
---@field has_storyboard boolean
---@field has_subtitles boolean
---@field has_negative_speed boolean
---@field has_stacked_notes boolean
---@field breaks_count integer
---@field played_at integer
---@field added_at integer
---@field created_at integer
---@field plays_count integer
---@field pitch number
---@field audio_channels integer
---@field used_columns integer
---@field comment string
---@field chart_preview string
local Chartmeta = class()

local is_timings_or_healths = valid.struct({
	name = types.name,
	data = valid.optional(types.count),
})

local text = types.description

local validate_chartmeta = valid.struct({
	hash = types.md5hash,
	index = types.index,
	timings = is_timings_or_healths,
	healths = is_timings_or_healths,
	title = text,
	title_unicode = text,
	artist = text,
	artist_unicode = text,
	name = text,
	creator = text,
	level = types.number,
	inputmode = types.name,
	source = text,
	tags = text,
	format = types.name,
	audio_path = text,
	background_path = text,
	preview_time = types.number,
	-- osu_beatmap_id = types.integer,
	-- osu_beatmapset_id = types.integer,
	-- osu_od = types.number,
	-- osu_hp = types.number,
	-- osu_ranked_status = types.new_enum(BeatmapStatus),
	tempo = types.number,
	duration = types.number,
	-- has_video = types.boolean,
	-- has_storyboard = types.boolean,
	-- has_subtitles = types.boolean,
	-- has_negative_speed = types.boolean,
	-- has_stacked_notes = types.boolean,
	-- breaks_count = types.count,
	-- played_at = types.time,
	-- added_at = types.time,
	-- created_at = types.time,
	-- plays_count = types.count,
	-- pitch = types.number,
	-- audio_channels = types.count,
	-- used_columns = types.count,
	-- comment = text,
	-- chart_preview = types.binary,
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
