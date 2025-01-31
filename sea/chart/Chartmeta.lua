local class = require("class")

---@class sea.Chartmeta
---@operator call: sea.Chartmeta
---@field id integer
---@field hash string
---@field index integer
---@field timings sea.Timings
---@field healths sea.Healths
---@field title string
---@field artist string
---@field name string
---@field creator string
---@field level number
---@field inputmode string
---@field source string
---@field tags string
---@field format string
---@field audio_path string
---@field background_path string
---@field preview_time string
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

return Chartmeta
