local thread = require("thread")
local erfunc = require("libchart.erfunc")
local class = require("class")
local Chartkey = require("sea.chart.Chartkey")
local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@class sphere.ScoreLibrary
---@operator call: sphere.ScoreLibrary
local ScoreLibrary = class()

ScoreLibrary.scoreSources = {
	"local",
	"online",
}

---@param configModel sphere.ConfigModel
---@param onlineModel sphere.OnlineModel
---@param cacheModel sphere.CacheModel
function ScoreLibrary:new(configModel, onlineModel, cacheModel)
	self.configModel = configModel
	self.onlineModel = onlineModel
	self.cacheModel = cacheModel

	self.items = {}
end

function ScoreLibrary:clear()
	self.items = {}
end

---@param scores table
---@return table
function ScoreLibrary:filterScores(scores)
	for _, score in ipairs(scores) do
		local s = erfunc.erf(0.032 / (score.accuracy * math.sqrt(2)))
		score.score = s * 10000
	end

	local filters = self.configModel.configs.filters.score
	local select = self.configModel.configs.select
	local index
	for i, filter in ipairs(filters) do
		if filter.name == select.scoreFilterName then
			index = i
			break
		end
	end
	index = index or 1
	local filter = filters[index]
	if not filter.check then
		return scores
	end
	local newScores = {}
	for i, score in ipairs(scores) do
		if filter.check(score) then
			table.insert(newScores, score)
		end
	end
	return newScores
end

---@param chartview table
---@param exact boolean?
---@return nil?
function ScoreLibrary:updateItemsAsync(chartview, exact)
	if not chartview.hash or not chartview.index then
		self.items = {}
		return
	end

	self.items = {}

	local select = self.configModel.configs.select
	if select.scoreSourceName == "online" then
		self:updateItemsOnline(chartview, exact)
	else
		self:updateItemsLocal(chartview, exact)
	end

	-- if self.hash .. self.index ~= hash_index then
	-- 	return self:updateItemsAsync(chartview, exact)
	-- end
end

ScoreLibrary.updateItems = thread.coro(ScoreLibrary.updateItemsAsync)

---@param chartview table
---@param exact boolean?
function ScoreLibrary:updateItemsOnline(chartview, exact)
	local remote = self.onlineModel.authManager.sea_client.remote

	---@type sea.Chartplay[]?, string?
	local chartplays, err
	if exact then
		local chartkey = Chartkey()
		chartkey:importChartkey(chartview)
		chartplays, err = remote.submission:getBestChartplaysForChartdiff(chartkey)
	else
		local chartmeta_key = ChartmetaKey()
		chartmeta_key:importChartmetaKey(chartview)
		chartplays, err = remote.submission:getBestChartplaysForChartmeta(chartmeta_key)
	end
	if not chartplays then
		print(err)
	end
	chartplays = chartplays or {}

	self.items = self:filterScores(chartplays)
end

---@param chartview table
---@param exact boolean?
function ScoreLibrary:updateItemsLocal(chartview, exact)
	---@type sea.Chartplay[]
	local chartplays
	if exact then
		chartplays = self.cacheModel.chartsRepo:getChartplaysForChartdiff(chartview)
	else
		chartplays = self.cacheModel.chartsRepo:getChartplaysForChartmeta(chartview)
	end
	self.items = self:filterScores(chartplays)
end

---@param chartplay_id number
---@return number
function ScoreLibrary:getItemIndex(chartplay_id)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local item = items[i]
		if item.id == chartplay_id then
			return i
		end
	end

	return 1
end

return ScoreLibrary
