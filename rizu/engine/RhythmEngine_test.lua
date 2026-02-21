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
function test.skip_intro(t)
	local re = RhythmEngine()

	local chart_chartmeta = get_chart([[
0100 =1
0010 =2
]])

	local chartdiff = {start_time = 10, duration = 2}
	re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
	re:load()

	re:setPlayTime(10, 2)
	re:setTimeToPrepare(2)

	-- Initial time should be 0 (if audio start is 0 and 10-2=8)
	-- Actually RhythmEngine:setTimeToPrepare does:
	-- local time_to_prepare = math.min(start_time - time, self.audio_engine:getStartTime())
	-- If getStartTime is 0, then init_time is 0.

	re:setTime(0)
	re:skipIntro()
	t:eq(re:getTime(), 8)
end

---@param t testing.T
function test.visual_rate_with_rate(t)
	local re = RhythmEngine()

	re:setRate(0.5)
	re:setVisualRate(1, false) -- scale_visual_rate = false

	-- visual_rate should be 1 / 0.5 = 2
	t:eq(re.visual_info.rate, 2)

	re:setRate(2)
	re:setVisualRate(1, false)
	t:eq(re.visual_info.rate, 0.5)
end
---@param t testing.T
function test.state_reset(t)
	local chart_chartmeta = get_chart([[
1000 =1
0100 =50
]])
	local chartdiff = {start_time = 1, duration = 2, notes_count = 2}

	local function create_and_run()
		local re = RhythmEngine()
		re:setChart(chart_chartmeta.chart, chart_chartmeta.chartmeta, chartdiff)
		re.audio_engine.getStartTime = function() return 100 end
		re:load()
		re:setPlayTime(1, 2)
		re:setTimeToPrepare(0.5)
		return re
	end

	local re = create_and_run()
	re:setGlobalTime(0)
	re:play()
	re:setGlobalTime(1)
	re:update()

	-- At 1.5s, some notes should be visible/active
	t:eq(re:getTime(), 1.5)
	t:assert(#re.visual_engine.visible_notes > 0)
	t:assert(#re.logic_engine.active_notes > 0)

	re:unload()
	re = create_and_run()

	-- After recreation (retry), it should be clean and time reset to init_time (0.5)
	t:eq(re:getTime(), 0.5)
	-- Initial state: only first note might be visible depending on implementation
	-- but it shouldn't have the 1.5s state.
	t:eq(#re.visual_engine.visible_notes, 1)
	t:eq(#re.logic_engine.active_notes, 2)
end

---@param t testing.T
function test.loader_order(t)
	local RhythmEngineLoader = require("rizu.gameplay.RhythmEngineLoader")
	local TimingValues = require("sea.chart.TimingValues")
	local re = RhythmEngine()

	local chart_chartmeta = get_chart([[
1000 =1
0100 =2
]])
	local chartdiff = {start_time = 10, duration = 2}

	local config = {
		gameplay = {
			time = {prepare = 2},
			longNoteShortening = 0,
			speed = 1,
			scaleSpeed = false,
		},
		audio = {
			adjustRate = 0.1,
			volume = {master = 1, music = 1, effects = 1},
			mode = {primary = "a", secondary = "b"},
		},
	}

	re.audio_engine.getStartTime = function() return 100 end

	local loader = RhythmEngineLoader(
		{rate = 1, timings = {name = "sphere"}, subtimings = nil, timing_values = TimingValues(), nearest = false, const = false},
		{chart = chart_chartmeta.chart, chartmeta = chart_chartmeta.chartmeta, chartdiff = chartdiff, state = {}},
		config,
		{}
	)

	loader:load(re)

	-- If setPlayTime(10, 2) was called BEFORE setTimeToPrepare(2)
	-- then RhythmEngine:setTimeToPrepare(2) used start_time = 10
	-- and set time to 10 - 2 = 8.
	-- If the order was wrong, it might have used start_time = 0 and set time to -2.

	t:eq(re:getTime(), 8)
end

---@param t testing.T
function test.double_unload(t)
	local re = RhythmEngine()
	t:has_not_error(function()
		re:unload()
		re:unload()
	end)
end

return test
