local aquathread = require("thread")
local Class = require("Class")

local ScoreLibraryModel = Class:new()

ScoreLibraryModel.scoreSources = {
	"local",
	"online",
}
ScoreLibraryModel.scoreSourceName = "local"

ScoreLibraryModel.construct = function(self)
	self.hash = ""
	self.index = 1
	self.items = {}
end

ScoreLibraryModel.clear = function(self)
	self.items = {}
end

ScoreLibraryModel.setHash = function(self, hash)
	self.hash = hash
end

ScoreLibraryModel.setIndex = function(self, index)
	self.index = index
end

ScoreLibraryModel.filterScores = function(self, scores)
	local filters = self.game.configModel.configs.filters.score
	local select = self.game.configModel.configs.select
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

ScoreLibraryModel.updateItemsAsync = function(self)
	local hash_index = self.hash .. self.index
	self.items = {}

	local select = self.game.configModel.configs.select
	if select.scoreSourceName == "online" then
		self:updateItemsOnline()
	else
		self:updateItemsLocal()
	end

	if self.hash .. self.index ~= hash_index then
		return self:updateItemsAsync()
	end
end

ScoreLibraryModel.updateItems = aquathread.coro(ScoreLibraryModel.updateItemsAsync)

ScoreLibraryModel.updateItemsOnline = function(self)
	local api = self.game.onlineModel.webApi.api

	print("GET " .. api.notecharts)
	local notecharts = api.notecharts:get({
		hash = self.hash,
		index = self.index,
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
	self.scoreSourceName = "online"

	for i, score in ipairs(self.items) do
		self.items[i] = self:transformOnlineScore(score)
	end
end

ScoreLibraryModel.updateItemsLocal = function(self)
	local scoreEntries = self.game.scoreModel:getScoreEntries(
		self.hash,
		self.index
	)
	table.sort(scoreEntries, function(a, b)
		return a.rating > b.rating
	end)
	scoreEntries = self:filterScores(scoreEntries)
	for i = 1, #scoreEntries do
		scoreEntries[i].rank = i
	end
	self.items = scoreEntries
	self.scoreSourceName = "local"
end

ScoreLibraryModel.getItemIndex = function(self, scoreEntryId)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local item = items[i]
		if item.id == scoreEntryId then
			return i
		end
	end

	return 1
end

ScoreLibraryModel.transformOnlineScore = function(self, score)
	local s = {
		id = score.id,
		noteChartHash = "",
		noteChartIndex = 1,
		isTop = false,
		playerName = score.user.name,
		time = score.created_at,
		accuracy = score.accuracy,
		maxCombo = score.max_combo,
		modifiers = score.modifierset.encoded,
		replayHash = score.file.hash,
		pauses = 0,
		ratio = score.ratio0,
		perfect = 0,
		notPerfect = 0,
		missCount = score.misses_count,
		mean = 0,
		earlylate = 0,
		inputMode = score.inputmode,
		timeRate = score.modifierset.timerate,
		difficulty = score.difficulty,
		pausesCount = 0,
	}
	for k, v in pairs(s) do
		score[k] = v
	end
	return score
end

return ScoreLibraryModel
