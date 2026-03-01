local class = require("class")
local stbl = require("stbl")

---@class sphere.ScoreTask
---@operator call: sphere.ScoreTask
local ScoreTask = class()

---@param chartsRepo sea.ChartsRepo
---@param chartsComputer sea.ChartsComputer
---@param checkProgress fun(state: integer, count: integer, current: integer)
---@param shouldStop fun(): boolean
function ScoreTask:new(chartsRepo, chartsComputer, checkProgress, shouldStop)
	self.chartsRepo = chartsRepo
	self.chartsComputer = chartsComputer
	self.checkProgress = checkProgress
	self.shouldStop = shouldStop
end

function ScoreTask:computeAll()
	local chartsRepo = self.chartsRepo
	local chartsComputer = self.chartsComputer

	local chartplays = chartsRepo:getChartplaysComputed(os.time(), "new", 1e6)
	print("ScoreTask: processing chartplays", #chartplays)

	local count = #chartplays
	local current = 0
	self.checkProgress(3, count, current)

	for i, chartplay in ipairs(chartplays) do
		if self.shouldStop() then break end
		local ret, err = chartsComputer:computeChartplay(chartplay)
		if not ret then
			print("ScoreTask: " .. chartplay.replay_hash .. ": " .. err)
		else
			-- Optional: print some summary
			-- print(stbl.encode(ret.chartplay_computed))
		end

		current = i
		self.checkProgress(3, count, current)
	end
end

return ScoreTask
