local class = require("class")
local stbl = require("stbl")

---@class sphere.ScoreTask
---@operator call: sphere.ScoreTask
local ScoreTask = class()

---@param chartsRepo sea.ChartsRepo
---@param chartsComputer sea.ChartsComputer
---@param cacheManager sphere.CacheManager
function ScoreTask:new(chartsRepo, chartsComputer, cacheManager)
	self.chartsRepo = chartsRepo
	self.chartsComputer = chartsComputer
	self.cacheManager = cacheManager
end

function ScoreTask:computeAll()
	local chartsRepo = self.chartsRepo
	local chartsComputer = self.chartsComputer

	local chartplays = chartsRepo:getChartplaysComputed(os.time(), "new", 1e6)
	print("ScoreTask: processing chartplays", #chartplays)

	self.cacheManager.chartfiles_count = #chartplays
	self.cacheManager.chartfiles_current = 0
	self.cacheManager.state = 1
	self.cacheManager:checkProgress()

	for i, chartplay in ipairs(chartplays) do
		local ret, err = chartsComputer:computeChartplay(chartplay)
		if not ret then
			print("ScoreTask: " .. chartplay.replay_hash .. ": " .. err)
		else
			-- Optional: print some summary
			-- print(stbl.encode(ret.chartplay_computed))
		end

		self.cacheManager.chartfiles_current = i
		self.cacheManager:checkProgress()
		if self.cacheManager.needStop then break end
	end

	self.cacheManager.state = 0
	self.cacheManager:checkProgress()
end

return ScoreTask
