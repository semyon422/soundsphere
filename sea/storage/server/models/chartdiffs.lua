local int_rates = require("libchart.int_rates")
local json = require("web.json")
local Gamemode = require("sea.chart.Gamemode")
local Chartdiff = require("sea.chart.Chartdiff")

---@type rdb.ModelOptions
local chartdiffs = {}

chartdiffs.metatable = Chartdiff

chartdiffs.types = {
	modifiers = json,
	rate = int_rates,
	mode = Gamemode,
}

return chartdiffs
