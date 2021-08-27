local Class = require("aqua.util.Class")

local CollectionModel = Class:new()

CollectionModel.load = function(self)
	self.config = self.configModel:getConfig("select")
	local collectionPath = self.config.collection

	local dict = {}
	for _, chartSetData in ipairs(self.cacheModel.cacheManager:getNoteChartSets()) do
		dict[chartSetData.path:match("^(.+)/.-$")] = true
	end

	local directoryItems = love.filesystem.getDirectoryItems("userdata/charts")
	for _, name in ipairs(directoryItems) do
		dict["userdata/charts/" .. name] = true
	end

	local items = {{path = "userdata/charts"}}
	for path in pairs(dict) do
		local collection = {path = path}
		items[#items + 1] = collection
		if path == collectionPath then
			self.collection = collection
		end
	end
	table.sort(items, function(a, b) return a.path < b.path end)
	self.collection = self.collection or items[1]

	self.items = items
end

CollectionModel.setCollection = function(self, collection)
	self.collection = collection
	self.config.collection = collection.path
end

return CollectionModel
