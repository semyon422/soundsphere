local DifficultyTask = require("sphere.persistence.CacheModel.DifficultyTask")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")

local test = {}

function test.computeMissing(t)
	local chartsRepo = {
		getChartplaysMissingChartdiffs = function() return {{hash = "score_hash", index = 1, modifiers = {}, rate = 1}} end,
		getChartmetasMissingChartdiffs = function() return {{hash = "meta_hash", index = 1}} end,
		createUpdateChartdiff = function(_, chartdiff, time)
		end
	}
	
	local difficultyModel = {
		compute = function() end
	}
	
	local chartdiffGenerator = {
		compute = function(_, chart, rate)
			return {rate = rate}
		end
	}
	
	local context = FakeTaskContext()
	context.charts["meta_hash"] = {{index = 1, layers = {main = {toAbsolute = function() end}}}}
	context.charts["score_hash"] = {{index = 1, layers = {main = {toAbsolute = function() end}}}}
	
	local task = DifficultyTask(difficultyModel, chartdiffGenerator, chartsRepo, context)
	
	task:computeMissing()
	
	-- Sequence of actions in context:
	-- progress (initial)
	-- db_begin
	-- get_charts (meta)
	-- progress
	-- get_charts (score)
	-- progress
	-- db_commit
	
	t:eq(context.actions[1][1], "checkProgress")
	t:eq(context.actions[2][1], "dbBegin")
	t:eq(context.actions[3][1], "getChartsByHash")
	t:eq(context.actions[3][2], "meta_hash")
	t:eq(context.actions[5][1], "getChartsByHash")
	t:eq(context.actions[5][2], "score_hash")
	t:eq(context.actions[7][1], "dbCommit")
end

return test
