local class = require("class")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Visual = require("ncdk2.visual.Visual")
local InputMode = require("ncdk.InputMode")
local Note = require("notechart.Note")
local Tempo = require("ncdk2.to.Tempo")
local Velocity = require("ncdk2.visual.Velocity")
local Chartmeta = require("sea.chart.Chartmeta")
local Chartdiff = require("sea.chart.Chartdiff")

---@class sea.chart.TestChartFactory
---@operator call: sea.chart.TestChartFactory
local TestChartFactory = class()

---@param inputmode_str string e.g. "4key"
---@param notes_table table[] e.g. {{time = 0, column = 1, velocity = {1, 1, 1}}, {time = 1, column = 2, end_time = 2}}
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta, chartdiff: sea.Chartdiff}
function TestChartFactory:create(inputmode_str, notes_table)
	local chart = Chart()
	chart.inputMode = InputMode(inputmode_str)
	local inputMap = chart.inputMode:getInputs()

	local layer = AbsoluteLayer()
	chart.layers.main = layer

	local visual = Visual()
	visual.primaryTempo = 120
	layer.visuals[""] = visual

	-- Set initial tempo at time 0
	local start_point = layer:getPoint(0)
	start_point._tempo = Tempo(120)

	local notes_count = 0
	local judges_count = 0
	local min_time = math.huge
	local max_time = -math.huge
	local note_types_count = {tap = 0, hold = 0}

	for _, n in ipairs(notes_table) do
		local point = layer:getPoint(n.time)
		local vp = visual:getPoint(point)

		if n.velocity then
			vp._velocity = Velocity(unpack(n.velocity))
		end

		if n.column then
			local column = inputMap[n.column] or inputMap[1]

			if n.end_time then
				-- Long Note
				local start_note = Note(vp, column, "hold", 1)
				
				local end_point = layer:getPoint(n.end_time)
				local end_vp = visual:getPoint(end_point)
				local end_note = Note(end_vp, column, "hold", -1)
				
				chart.notes:insert(start_note)
				chart.notes:insert(end_note)
				
				note_types_count.hold = note_types_count.hold + 1
				notes_count = notes_count + 1
				judges_count = judges_count + 2
				min_time = math.min(min_time, n.time)
				max_time = math.max(max_time, n.end_time)
			else
				-- Tap Note
				local note = Note(vp, column, "tap", 0)
				chart.notes:insert(note)
				
				note_types_count.tap = note_types_count.tap + 1
				notes_count = notes_count + 1
				judges_count = judges_count + 1
				min_time = math.min(min_time, n.time)
				max_time = math.max(max_time, n.time)
			end
		end
	end

	chart:compute()

	if min_time == math.huge then
		min_time = 0
		max_time = 0
	end

	local chartmeta = Chartmeta()
	chartmeta.inputmode = inputmode_str
	chartmeta.format = "sph"
	chartmeta.title = "Test Title"
	chartmeta.artist = "Test Artist"
	chartmeta.tempo = 120
	chartmeta.tempo_avg = 120
	chartmeta.tempo_min = 120
	chartmeta.tempo_max = 120

	local chartdiff = Chartdiff()
	chartdiff.inputmode = inputmode_str
	chartdiff.notes_count = notes_count
	chartdiff.judges_count = judges_count
	chartdiff.start_time = min_time
	chartdiff.duration = max_time - min_time
	chartdiff.note_types_count = note_types_count
	chartdiff.enps_diff = 1
	chartdiff.osu_diff = 1
	chartdiff.msd_diff = 1
	chartdiff.msd_diff_data = {
		overall = 1, stream = 0, jumpstream = 0, handstream = 0,
		stamina = 0, jackspeed = 0, chordjack = 0, technical = 0
	}
	chartdiff.msd_diff_rates = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}

	return {
		chart = chart,
		chartmeta = chartmeta,
		chartdiff = chartdiff,
	}
end

return TestChartFactory
