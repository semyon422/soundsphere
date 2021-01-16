local Class = require("aqua.util.Class")
local SearchManager			= require("sphere.database.SearchManager")

local ScoreLibraryModel = Class:new()

ScoreLibraryModel.construct = function(self)
	self:setHash("")
	self:setIndex(1)
end

ScoreLibraryModel.setHash = function(self, hash)
	self.hash = hash
	self.items = nil
end

ScoreLibraryModel.setIndex = function(self, index)
	self.index = index
	self.items = nil
end

ScoreLibraryModel.getItems = function(self)
	if not self.items then
		self:updateItems()
	end
	return self.items
end

ScoreLibraryModel.updateItems = function(self)
	local items = {}
	self.items = items

	local scoreEntries = self.scoreModel:getScoreEntries(
		self.hash,
		self.index
	)
	if not scoreEntries or not scoreEntries[1] then
		return items
	end

	for _, scoreEntry in ipairs(scoreEntries) do
		items[#items + 1] = {
			scoreEntry = scoreEntry
		}
	end

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
