local Class = require("aqua.util.Class")

local ScoreLibraryModel = Class:new()

ScoreLibraryModel.construct = function(self)
	self.hash = ""
	self.index = 1
	self.items = {}
end

ScoreLibraryModel.setHash = function(self, hash)
	self.hash = hash
end

ScoreLibraryModel.setIndex = function(self, index)
	self.index = index
end

ScoreLibraryModel.updateItems = function(self)
	local scoreEntries = self.scoreModel:getScoreEntries(
		self.hash,
		self.index
	)
	table.sort(scoreEntries, function(a, b)
		return a.rating > b.rating
	end)
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
