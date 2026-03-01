local ScoreTask = require("sphere.persistence.CacheModel.ScoreTask")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")

local test = {}

function test.computeAll(t)
	local chartsRepo = {
		getChartplaysComputed = function() return {{replay_hash = "replay1"}} end
	}
	
	local chartsComputer = {
		computeChartplay = function(_, chartplay)
			return {chartplay_computed = {}}
		end
	}
	
	local context = FakeTaskContext()
	local task = ScoreTask(chartsRepo, chartsComputer, context)
	
	task:computeAll()
	
	t:tdeq(context.actions[1], {"checkProgress", 3, 1, 0})
	t:tdeq(context.actions[2], {"dbBegin"})
	t:tdeq(context.actions[3], {"checkProgress", 3, 1, 1})
	t:tdeq(context.actions[4], {"dbCommit"})
end

return test
