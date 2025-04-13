local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValues = require("sea.chart.TimingValues")
local Healths = require("sea.chart.Healths")

local play = {
	modifiers = {},
	rate = 1,
	mode = "mania",

	nearest = false,
	tap_only = false,
	timings = Timings("sphere"),
	subtimings = Subtimings("none"),
	healths = Healths("simple", 20),
	columns_order = nil,

	custom = false,
	const = false,
	rate_type = "linear",

	timing_values = TimingValues(Timings("sphere"), Subtimings("none")),
}

return play
