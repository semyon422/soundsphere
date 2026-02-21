local RhythmEngine = require("rizu.engine.RhythmEngine")
local AutoplayPlayer = require("rizu.engine.autoplay.AutoplayPlayer")
local ChartFactory = require("notechart.ChartFactory")
local TimingValues = require("sea.chart.TimingValues")

local cf = ChartFactory()
local test_chart_header = [[
# metadata
title Title
artist Artist
name Name
creator Creator
input 4key

# notes
]]

---@param notes string
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}
local function get_chart(notes)
	return assert(cf:getCharts("chart.sph", test_chart_header .. notes))[1]
end

local test = {}

---@param t testing.T
function test.autoplay_short_note(t)
	local re = RhythmEngine()
	local ap = AutoplayPlayer()

	local chart_chartmeta = get_chart([[
1000 =1
0100 =2
]])

	local chartdiff = {notes_count = 2}
	re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
	re:setTimingValues(TimingValues())
	re:load()

	local received_events = {}
	re.receive = function(self, event)
		table.insert(received_events, {id = event.id, value = event.value, time = re:getTime()})
	end

	re:setTime(0)
	ap:update(re, 0.9)
	t:eq(#received_events, 0)

	ap:update(re, 1.1)
	t:eq(#received_events, 2)
	if received_events[1] then
		t:eq(received_events[1].value, true)
		t:eq(received_events[1].time, 1.0)
	end
	if received_events[2] then
		t:eq(received_events[2].value, false)
		t:eq(received_events[2].time, 1.0)
	end
end

---@param t testing.T
function test.autoplay_long_note(t)
	local re = RhythmEngine()
	local ap = AutoplayPlayer()

	local chart_chartmeta = get_chart([[
2000 =1
3000 =2
]])

	local chartdiff = {notes_count = 1}
	re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
	re:setTimingValues(TimingValues())
	re:load()

	local received_events = {}
	re.receive = function(self, event)
		table.insert(received_events, {id = event.id, value = event.value, time = re:getTime()})
	end

	re:setTime(0)
	ap:update(re, 0.9)
	t:eq(#received_events, 0)

	ap:update(re, 1.1)
	t:eq(#received_events, 1)
	if received_events[1] then
		t:eq(received_events[1].value, true)
		t:eq(received_events[1].time, 1.0)
	end

	ap:update(re, 1.9)
	t:eq(#received_events, 1)

	ap:update(re, 2.1)
	t:eq(#received_events, 2)
	if received_events[2] then
		t:eq(received_events[2].value, false)
		t:eq(received_events[2].time, 2.0)
	end
end

return test
