local thread = require("thread")
local erfunc = require("libchart.erfunc")
local class = require("class")

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
		self:updateItemsOnline(chartview)
	else
		self:updateItemsLocal(chartview, exact)
	end

	-- if self.hash .. self.index ~= hash_index then
	-- 	return self:updateItemsAsync(chartview, exact)
	-- end
end

ScoreLibrary.updateItems = thread.coro(ScoreLibrary.updateItemsAsync)

---@param chartview table
function ScoreLibrary:updateItemsOnline(chartview)
	local api = self.onlineModel.webApi.api

	print("GET " .. api.notecharts)
	local notecharts = api.notecharts:get({
		hash = chartview.hash,
		index = chartview.index,
	})
	local id = notecharts and notecharts[1] and notecharts[1].id

	if not id then
		return
	end

	print("GET " .. api.notecharts[id].scores)
	local scores = api.notecharts[id].scores:get({
		user = true,
		file = true,
		modifierset = true,
	})
	self.items = scores or {}

	for i, score in ipairs(self.items) do
		self.items[i] = self:transformOnlineScore(score, chartview)
	end
end

---@param score table
function ScoreLibrary:fillScoreRating(score)
	local window = self.configModel.configs.settings.gameplay.ratingHitTimingWindow
	local s = erfunc.erf(window / (score.accuracy * math.sqrt(2)))
	score.rating = (score.difficulty or 0) * s
	score.score = s * 10000
end

---@param chartview table
---@param exact boolean?
function ScoreLibrary:updateItemsLocal(chartview, exact)
	local scores
	if exact then
		scores = self.cacheModel.scoresRepo:getScoresExact(chartview)
	else
		scores = self.cacheModel.scoresRepo:getScores(chartview)
	end

	for i, score in ipairs(scores) do
		self.cacheModel.chartdiffGenerator:fillMeta(score, chartview)
		self:fillScoreRating(score)
	end
	table.sort(scores, function(a, b)
		return a.rating > b.rating
	end)
	scores = self:filterScores(scores)
	for i, score in ipairs(scores) do
		score.rank = i
	end
	self.items = scores
end

---@param score_id number
---@return number
function ScoreLibrary:getItemIndex(score_id)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local item = items[i]
		if item.id == score_id then
			return i
		end
	end

	return 1
end

---@param score table
---@return table
function ScoreLibrary:transformOnlineScore(score, chartview)
	local s = {
		id = score.id,
		chart_hash = "",
		chart_index = 1,
		player_name = score.user.name,
		time = score.created_at,
		accuracy = score.accuracy,
		max_combo = score.max_combo,
		modifiers = score.modifierset.encoded,
		rate = score.modifierset.timerate,
		const = score.modifierset.const,
		replay_hash = score.file.hash,
		ratio = score.ratio0,
		perfect = 0,
		not_perfect = 0,
		miss = score.misses_count,
		mean = 0,
		earlylate = 0,
		inputmode = score.inputmode,
		difficulty = score.difficulty,
		pauses = 0,
	}
	for k, v in pairs(s) do
		score[k] = v
		self.cacheModel.chartdiffGenerator:fillMeta(score, chartview)
	end
	return score
end

return ScoreLibrary
