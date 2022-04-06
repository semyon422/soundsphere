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
	local items = {}
	self.items = items

	local scoreEntries = self.scoreModel:getScoreEntries(
		self.hash,
		self.index
	)
	if not scoreEntries or not scoreEntries[1] then
		self.firstScoreItem = nil
		return items
	end
	table.sort(scoreEntries, function(a, b)
		return a.rating > b.rating
	end)

	for itemIndex, scoreEntry in ipairs(scoreEntries) do
		items[#items + 1] = {
			itemIndex = itemIndex,
			scoreEntry = scoreEntry
		}
	end

	self.firstScoreItem = items[1]

	return items
end

ScoreLibraryModel.getItemIndex = function(self, scoreEntryId)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local item = items[i]
		if item.scoreEntry.id == scoreEntryId then
			return i
		end
	end

	return 1
end

return ScoreLibraryModel
