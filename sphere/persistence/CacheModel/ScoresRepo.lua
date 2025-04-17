local class = require("class")

---@class sphere.ScoresRepo
---@operator call: sphere.ScoresRepo
local ScoresRepo = class()

---@param gdb sphere.GameDatabase
function ScoresRepo:new(gdb)
	self.models = gdb.models
end

---@return table
function ScoresRepo:selectAllScores()
	return self.models.scores:select()
end

---@param id number
---@return table?
function ScoresRepo:selectScore(id)
	return self.models.scores:find({id = id})
end

---@param score table
---@return table
function ScoresRepo:insertScore(score)
	return self.models.scores:create(score)
end

---@param score table
---@return table?
function ScoresRepo:updateScore(score)
	return self.models.scores:update(score, {id = score.id})
end

---@param replay_hash string
---@return table?
function ScoresRepo:getScoreByReplayHash(replay_hash)
	return self.models.scores:find({
		replay_hash = assert(replay_hash),
	})
end

---@param chartview table
---@return table
function ScoresRepo:getScores(chartview)
	return self.models.chartplays_list:select({
		hash = assert(chartview.hash),
		index = assert(chartview.index),
	})
end

---@param chartview table
---@return table
function ScoresRepo:getScoresExact(chartview)
	return self.models.chartplays_list:select({
		hash = assert(chartview.hash),
		index = assert(chartview.index),
		modifiers = chartview.modifiers or {},
		rate = chartview.rate or 1,
	})
end

---@return table
function ScoresRepo:getScoresWithMissingChartdiffs()
	return self.models.chartplays_list:select({
		chartdiff_id__isnull = true,
		chartmeta_id__isnotnull = true,
	})
end

return ScoresRepo
