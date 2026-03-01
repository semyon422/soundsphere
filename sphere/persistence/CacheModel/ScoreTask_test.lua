local ScoreTask = require("sphere.persistence.CacheModel.ScoreTask")

local test = {}

function test.computeAll(t)
	local actions = {}
	
	local chartsRepo = {
		getChartplaysComputed = function() return {{replay_hash = "replay1"}} end
	}
	
	local chartsComputer = {
		computeChartplay = function(_, chartplay)
			table.insert(actions, {"compute", chartplay.replay_hash})
			return {chartplay_computed = {}}
		end
	}
	
	local function checkProgress(state, count, current)
		table.insert(actions, {"progress", state, count, current})
	end
	
	local function shouldStop() return false end
	
	local task = ScoreTask(chartsRepo, chartsComputer, checkProgress, shouldStop)
	
	task:computeAll()
	
	t:tdeq(actions[1], {"progress", 3, 1, 0})
	t:tdeq(actions[2], {"compute", "replay1"})
	t:tdeq(actions[3], {"progress", 3, 1, 1})
end

return test
