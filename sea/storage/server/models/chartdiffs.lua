local int_rates = require("libchart.int_rates")
local json = require("web.json")
local Gamemode = require("sea.chart.Gamemode")

---@type rdb.ModelOptions
local chartdiffs = {}

chartdiffs.table_name = "chartdiffs"

chartdiffs.types = {
	modifiers = json,
	rate = int_rates,
	mode = Gamemode,
}

chartdiffs.relations = {}

return chartdiffs
