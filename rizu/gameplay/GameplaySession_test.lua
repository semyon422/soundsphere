local GameplaySession = require("rizu.gameplay.GameplaySession")
local RhythmEngine = require("rizu.engine.RhythmEngine")
local TestChartFactory = require("sea.chart.TestChartFactory")
local TimingValues = require("sea.chart.TimingValues")

local tcf = TestChartFactory()

local test = {}

---@param t testing.T
function test.basic_lifecycle(t)
	local re = RhythmEngine()
	local gc = GameplaySession(re)
	
	local res = tcf:create("4key", {
		{time = 2, column = 1},
		{time = 3, column = 2},
	})
	re:setChart(res.chart, res.chartmeta, res.chartdiff)
	re:setTimingValues(TimingValues())
	re:load()
	re:setAudioEnabled(false)

	-- Test play/pause
	local play_called = false
	local pause_called = false
	re.play = function() play_called = true end
	re.pause = function() pause_called = true end

	gc:play()
	t:assert(play_called)

	gc:pause()
	t:assert(pause_called)

	-- Test update
	gc:update(100)
	t:eq(re.time_engine.timer.global_time, 100)
end

---@param t testing.T
function test.autoplay(t)
	local re = RhythmEngine()
	local gc = GameplaySession(re)
	
	local res = tcf:create("4key", {
		{time = 2, column = 1},
		{time = 3, column = 2},
	})
	re:setChart(res.chart, res.chartmeta, res.chartdiff)
	re:setTimingValues(TimingValues())
	re:load()
	re:setAudioEnabled(false)
	gc:setPlayType("auto")

	local received_events = {}
	re.receive = function(self, event)
		table.insert(received_events, event)
	end

	-- Initial time setup
	gc:update(0)
	re:play()
	re:setTime(0)
	
	-- Manually advance time by updating GameplaySession with new global time
	gc:update(2.1) -- trigger note at =2
	
	t:assert(#received_events >= 2, "Autoplay should have triggered note events")
end

---@param t testing.T
function test.input_recording(t)
	local re = RhythmEngine()
	local gc = GameplaySession(re)
	
	local res = tcf:create("4key", {
		{time = 2, column = 1},
	})
	re:setChart(res.chart, res.chartmeta, res.chartdiff)
	re:setTimingValues(TimingValues())
	re:load()
	re:setAudioEnabled(false)

	local event = {id = 1, value = true}
	gc:receive(event, 0)

	t:eq(#gc.replay_recorder.frames, 1)
	t:eq(gc.replay_recorder.frames[1].event, event)
end

---@param t testing.T
function test.has_result(t)
	local re = RhythmEngine()
	local gc = GameplaySession(re)
	
	local res = tcf:create("4key", {
		{time = 2, column = 1},
	})
	re:setChart(res.chart, res.chartmeta, res.chartdiff)
	re:setTimingValues(TimingValues())
	re:load()
	re:setAudioEnabled(false)
	re:setPlayTime(0, 10)

	-- Should not have result initially
	t:assert(not gc:hasResult())

	-- Mock score engine to have some hits
	re.score_engine.scores.base.hitCount = 1
	re:setTime(5)
	re.score_engine.scores.normalscore.accuracyAdjusted = 0.95
	
	t:assert(gc:hasResult())
	
	-- Should NOT have result if replaying
	gc:setPlayType("replay")
	t:assert(not gc:hasResult())
	
	-- Should NOT have result if autoplay
	gc:setPlayType("auto")
	t:assert(not gc:hasResult())
end

return test
