local Class = require("aqua.util.Class")

local CollectionModel = Class:new()

CollectionModel.collection = ""

CollectionModel.load = function(self)
	self.config = self.configModel:getConfig("select")
	self.collection = self.config.collection

	local dict = {}
	for _, chartSetData in ipairs(self.cacheModel.cacheManager:getNoteChartSets()) do
		dict[chartSetData.path:match("^(.+)/.-$")] = true
	end

	local directoryItems = love.filesystem.getDirectoryItems("userdata/charts")
	for _, name in ipairs(directoryItems) do
		dict["userdata/charts/" .. name] = true
	end

	local paths = {"userdata/charts"}
	for path in pairs(dict) do
		paths[#paths + 1] = path
	end
	table.sort(paths)

	self.items = paths
end

CollectionModel.setCollection = function(self, collection)
	self.collection = collection
	self.config.collection = collection
end

return CollectionModel
