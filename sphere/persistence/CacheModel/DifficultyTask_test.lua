local DifficultyTask = require("sphere.persistence.CacheModel.DifficultyTask")

local test = {}

function test.computeMissing(t)
	local actions = {}
	
	local chartsRepo = {
		getChartplaysMissingChartdiffs = function() return {{hash = "score_hash", index = 1, modifiers = {}, rate = 1}} end,
		getChartmetasMissingChartdiffs = function() return {{hash = "meta_hash", index = 1}} end,
		createUpdateChartdiff = function(_, chartdiff, time)
			table.insert(actions, {"create_update_diff", chartdiff.hash, chartdiff.index})
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
	
	local function getChartsByHash(hash)
		table.insert(actions, {"get_charts", hash})
		return {{index = 1, layers = {main = {toAbsolute = function() end}}}}
	end
	
	local function checkProgress(state, count, current)
		table.insert(actions, {"progress", state, count, current})
	end
	
	local function shouldStop() return false end
	
	local task = DifficultyTask(difficultyModel, chartdiffGenerator, chartsRepo, getChartsByHash, checkProgress, shouldStop)
	
	task:computeMissing()
	
	-- Expected actions sequence:
	-- 1. progress (initial)
	-- 2. get_charts (meta)
	-- 3. create_update_diff (meta)
	-- 4. progress
	-- 5. get_charts (score)
	-- 6. create_update_diff (score)
	-- 7. progress
	
	t:eq(actions[1][1], "progress")
	t:tdeq(actions[2], {"get_charts", "meta_hash"})
	t:tdeq(actions[3], {"create_update_diff", "meta_hash", 1})
	t:tdeq(actions[5], {"get_charts", "score_hash"})
	t:tdeq(actions[6], {"create_update_diff", "score_hash", 1})
end

return test
