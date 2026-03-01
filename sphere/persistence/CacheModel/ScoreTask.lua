local class = require("class")
local stbl = require("stbl")

---@class sphere.ScoreTask
---@operator call: sphere.ScoreTask
local ScoreTask = class()

---@param chartsRepo sea.ChartsRepo
---@param chartsComputer sea.ChartsComputer
---@param context sphere.ITaskContext
function ScoreTask:new(chartsRepo, chartsComputer, context)
	self.chartsRepo = chartsRepo
	self.chartsComputer = chartsComputer
	self.context = context
end

function ScoreTask:computeAll()
	local chartsRepo = self.chartsRepo
	local chartsComputer = self.chartsComputer
	local context = self.context

	local chartplays = chartsRepo:getChartplaysComputed(os.time(), "new", 1e6)
	print("ScoreTask: processing chartplays", #chartplays)

	local count = #chartplays
	local current = 0
	context:checkProgress(3, count, current)

	context:dbBegin()
	for i, chartplay in ipairs(chartplays) do
		if context:shouldStop() then break end
		local ret, err = chartsComputer:computeChartplay(chartplay)
		if not ret then
			context:addError("ScoreTask: " .. chartplay.replay_hash .. ": " .. tostring(err))
		else
			-- Optional: print some summary
			-- print(stbl.encode(ret.chartplay_computed))
		end

		current = i
		context:checkProgress(3, count, current)
		if i % 100 == 0 then
			context:dbCommit()
			context:dbBegin()
		end
	end
	context:dbCommit()
end

return ScoreTask
