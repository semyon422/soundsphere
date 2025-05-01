local Chartplayview = require("sea.chart.Chartplayview")
local Gamemode = require("sea.chart.Gamemode")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

local table_util = require("table_util")
local chartplays = require("sea.storage.server.models.chartplays")

---@type rdb.ModelOptions
local chartplayviews = {}

chartplayviews.metatable = Chartplayview

chartplayviews.types = {
	chartmeta_timings = Timings,
	chartmeta_healths = Healths,
}
table_util.copy(chartplays.types, chartplayviews.types)

chartplayviews.relations = {
	chartdiff = {belongs_to = "chartdiffs", key = "chartdiff_id"},
	chartmeta = {belongs_to = "chartmetas", key = "chartmeta_id"},
}

return chartplayviews
