local IJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.IJudgesSource")

---@class sphere.SimpleJudgesSource: sphere.IJudgesSource
---@operator call: sphere.SimpleJudgesSource
---@field judge_counter sphere.JudgeCounter
---@field judge_names string[]
local SimpleJudgesSource = IJudgesSource + {}

---@return integer[]
function SimpleJudgesSource:getJudges()
	return self.judge_counter.judges
end

---@return string[]
function SimpleJudgesSource:getJudgeNames()
	return self.judge_names
end

---@return integer
function SimpleJudgesSource:getJudgesTotal()
	return self.judge_counter.total
end

---@return integer?
function SimpleJudgesSource:getLastJudge()
	return self.judge_counter.last
end

---@return integer
function SimpleJudgesSource:getNotPerfect()
	return self.judge_counter:getNotPerfect()
end

return SimpleJudgesSource
