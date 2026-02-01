local RhythmEngine = require("rizu.engine.RhythmEngine")
local ChartFactory = require("notechart.ChartFactory")

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
function test.time_to_prepare(t)
	local re = RhythmEngine()

	local chart_chartmeta = get_chart([[
0100 =1
0010 =2
]])

	local chartdiff = {notes_count = 2}
	re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
	re:load()

	re:setPlayTime(1, 2)
	re:setTimeToPrepare(2)
	t:eq(re:getTime(), -1)

	re:setPlayTime(3, 4)
	re:setTimeToPrepare(2)
	t:eq(re:getTime(), 0)
end

---@param t testing.T
function test.retry(t)
	local re = RhythmEngine()

	local chart_chartmeta = get_chart([[
0100 =1
0010 =2
]])

	local chartdiff = {notes_count = 2}
	re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
	re:load()

	re:setPlayTime(1, 2)
	re:setTimeToPrepare(2)

	re:setGlobalTime(0)
	re:play()

	t:eq(re:getTime(), -1)

	re:setGlobalTime(1)
	t:eq(re:getTime(), 0)

	re:retry()
	t:eq(re:getTime(), -1)
end

return test
