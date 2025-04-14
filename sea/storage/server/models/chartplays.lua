local Result = require("sea.chart.Result")
local Gamemode = require("sea.chart.Gamemode")
local Chartplay = require("sea.chart.Chartplay")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

local subtimings = {}

---@param s integer
---@return integer
function subtimings.decode(s) return s end

---@param v sea.Subtimings
---@return integer
function subtimings.encode(v) return Subtimings.encode(v) end

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
	const = "boolean",
	rate = int_rates,
	timings = Timings,
	subtimings = subtimings,
	healths = Healths,
}

---@param chartplay sea.Chartplay
function chartplays.from_db(chartplay)
	---@diagnostic disable-next-line
	chartplay.subtimings = Subtimings.decode(chartplay.subtimings, chartplay.timings.name)
end

return chartplays
