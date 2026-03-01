local class = require("class")
local stbl = require("stbl")

---@class rizu.library.ScoreTask
---@operator call: rizu.library.ScoreTask
local ScoreTask = class()

---@param chartsRepo sea.ChartsRepo
---@param chartsComputer sea.ChartsComputer
---@param taskContext rizu.library.ITaskContext
function ScoreTask:new(chartsRepo, chartsComputer, taskContext)
	self.chartsRepo = chartsRepo
	self.chartsComputer = chartsComputer
	self.taskContext = taskContext
end

function ScoreTask:computeAll()
	local chartsRepo = self.chartsRepo
	local chartsComputer = self.chartsComputer
	local taskContext = self.taskContext

	local chartplays = chartsRepo:getChartplaysComputed(os.time(), "new", 1e6)
	print("ScoreTask: processing chartplays", #chartplays)

	local count = #chartplays
	local current = 0
	taskContext:checkProgress(3, count, current)

	taskContext:dbBegin()
	for i, chartplay in ipairs(chartplays) do
		if taskContext:shouldStop() then break end
		local ret, err = chartsComputer:computeChartplay(chartplay)
		if not ret then
			taskContext:addError("ScoreTask: " .. chartplay.replay_hash .. ": " .. tostring(err))
		else
			-- Optional: print some summary
			-- print(stbl.encode(ret.chartplay_computed))
		end

		current = i
		taskContext:checkProgress(3, count, current)
		if i % 100 == 0 then
			taskContext:dbCommit()
			taskContext:dbBegin()
		end
	end
	taskContext:dbCommit()
end

return ScoreTask
