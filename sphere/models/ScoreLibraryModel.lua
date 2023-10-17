local thread = require("thread")
local class = require("class")

---@class sphere.ScoreLibraryModel
---@operator call: sphere.ScoreLibraryModel
local ScoreLibraryModel = class()

ScoreLibraryModel.scoreSources = {
	"local",
	"online",
}
ScoreLibraryModel.scoreSourceName = "local"

---@param configModel sphere.ConfigModel
---@param onlineModel sphere.OnlineModel
---@param scoreModel sphere.ScoreModel
function ScoreLibraryModel:new(configModel, onlineModel, scoreModel)
	self.configModel = configModel
	self.onlineModel = onlineModel
	self.scoreModel = scoreModel

	self.hash = ""
	self.index = 1
	self.items = {}
end

function ScoreLibraryModel:clear()
	self.items = {}
end

---@param hash string?
function ScoreLibraryModel:setHash(hash)
	self.hash = hash or ""
end

---@param index number?
function ScoreLibraryModel:setIndex(index)
	self.index = index or 1
end

---@param scores table
---@return table
function ScoreLibraryModel:filterScores(scores)
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

---@return nil?
function ScoreLibraryModel:updateItemsAsync()
	local hash_index = self.hash .. self.index
	self.items = {}

	local select = self.configModel.configs.select
	if select.scoreSourceName == "online" then
		self:updateItemsOnline()
	else
		self:updateItemsLocal()
	end

	if self.hash .. self.index ~= hash_index then
		return self:updateItemsAsync()
	end
end

ScoreLibraryModel.updateItems = thread.coro(ScoreLibraryModel.updateItemsAsync)

function ScoreLibraryModel:updateItemsOnline()
	local api = self.onlineModel.webApi.api

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

function ScoreLibraryModel:updateItemsLocal()
	local scoreEntries = self.scoreModel:getScoreEntries(
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

---@param scoreEntryId number
---@return number
function ScoreLibraryModel:getItemIndex(scoreEntryId)
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

---@param score table
---@return table
function ScoreLibraryModel:transformOnlineScore(score)
	local s = {
		id = score.id,
		chart_hash = "",
		chart_index = 1,
		is_top = false,
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
	end
	return score
end

return ScoreLibraryModel
