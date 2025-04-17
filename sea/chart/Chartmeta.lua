local table_util = require("table_util")
local valid = require("valid")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local ChartFormat = require("sea.chart.ChartFormat")
local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@class sea.Chartmeta: sea.ChartmetaKey
---@operator call: sea.Chartmeta
--- EXTERNAL
---@field id integer
---@field created_at integer
---@field osu_ranked_status integer
--- CLIENT-ONLY
---@field offset number
--- ChartmetaKey
--- COMPUTED
---@field timings sea.Timings?
---@field healths sea.Healths?
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
---@field format sea.ChartFormat
---@field audio_path string
---@field audio_offset string
---@field background_path string
---@field preview_time number
---@field osu_beatmap_id integer
---@field osu_beatmapset_id integer
---@field tempo number
---@field tempo_avg number
---@field tempo_max number
---@field tempo_min number
local Chartmeta = ChartmetaKey + {}

local text = types.description

Chartmeta.struct = {
	timings = valid.optional(chart_types.timings),
	healths = valid.optional(chart_types.healths),
	title = text,
	title_unicode = valid.optional(text),
	artist = text,
	artist_unicode = valid.optional(text),
	name = text,
	creator = text,
	level = valid.optional(types.number),
	inputmode = chart_types.inputmode,
	source = valid.optional(text),
	tags = valid.optional(text),
	format = types.new_enum(ChartFormat),
	audio_path = valid.optional(text),
	audio_offset = valid.optional(types.number),
	background_path = valid.optional(text),
	preview_time = valid.optional(types.number),
	osu_beatmap_id = valid.optional(types.integer),
	osu_beatmapset_id = valid.optional(types.integer),
	tempo = types.number,
	tempo_avg = valid.optional(types.number),
	tempo_max = valid.optional(types.number),
	tempo_min = valid.optional(types.number),
}
table_util.copy(ChartmetaKey.struct, Chartmeta.struct)

assert(#table_util.keys(Chartmeta.struct) == 25)

local validate_chartmeta = valid.struct(Chartmeta.struct)

local computed_keys = table_util.keys(Chartmeta.struct)

---@param values sea.Chartmeta
---@return boolean
function Chartmeta:equalsComputed(values)
	return table_util.subequal(self, values, computed_keys, table_util.equal)
end

---@return true?
---@return string|util.Errors?
function Chartmeta:validate()
	return validate_chartmeta(self)
end

return Chartmeta
