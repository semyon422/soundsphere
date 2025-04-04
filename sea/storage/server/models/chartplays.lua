local Result = require("sea.chart.Result")
local Gamemode = require("sea.chart.Gamemode")
local Chartplay = require("sea.chart.Chartplay")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

---@type rdb.ModelOptions
local chartplays = {}

chartplays.metatable = Chartplay

chartplays.types = {
	nearest = "boolean",
	result = Result,
	mode = Gamemode,
	custom = "boolean",
	columns_order = json,
	modifiers = json,
	judges = json,
	tap_only = "boolean",
	rate = int_rates,
	timings = Timings,
	healths = Healths,
}

return chartplays
