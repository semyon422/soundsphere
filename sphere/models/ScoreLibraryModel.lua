local Class = require("aqua.util.Class")

local ScoreLibraryModel = Class:new()

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

ScoreLibraryModel.updateItems = function(self)
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

return ScoreLibraryModel
