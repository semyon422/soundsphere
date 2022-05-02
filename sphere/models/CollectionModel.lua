local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local CollectionModel = Class:new()

CollectionModel.basePath = "userdata/charts"

CollectionModel.load = function(self)
	self.config = self.configModel.configs.select
	local collectionPath = self.config.collection
	local basePath = self.basePath

	local dict = {}
	for _, chartSetData in ipairs(CacheDatabase:selectNoteChartSets(self.basePath)) do
		local parent = chartSetData.path:match("^(.+)/.-$")
		dict[parent] = (dict[parent] or 0) + 1
	end

	local directoryItems = love.filesystem.getDirectoryItems(basePath)
	for _, name in ipairs(directoryItems) do
		local path = basePath .. "/" .. name
		dict[path] = dict[path] or 0
	end

	local items = {{
		path = basePath,
		shortPath = "/",
		name = "/",
		count = 0
	}}
	for path, count in pairs(dict) do
		local collection = {
			path = path,
			shortPath = path:gsub(basePath .. "/", ""),
			name = path:match("^.+/(.-)$"),
			count = count
		}
		items[#items + 1] = collection
		if path == collectionPath then
			self.collection = collection
		end
	end
	table.sort(items, function(a, b) return a.path < b.path end)
	self.collection = self.collection or items[1]

	self.items = items
end

CollectionModel.getItemIndex = function(self, path)
	local items = self.items

	if not items then
		return 1
	end

	for i = 1, #items do
		local collection = items[i]
		if collection.path == path then
			return i
		end
	end

	return 1
end

return CollectionModel
