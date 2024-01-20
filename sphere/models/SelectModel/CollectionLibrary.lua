local class = require("class")

---@class sphere.CollectionLibrary
---@operator call: sphere.CollectionLibrary
local CollectionLibrary = class()

CollectionLibrary.basePath = "userdata/charts"

local ignoredNames = {
	".keep",
}
for i = 1, #ignoredNames do
	ignoredNames[ignoredNames[i]] = true
end

function CollectionLibrary:load()
	self.config = self.configModel.configs.select
	local collectionPath = self.config.collection
	local basePath = self.basePath

	local dict = {}
	for _, chartSetData in ipairs(self.cacheModel.chartRepo:selectChartfileSetsAtPath(self.basePath)) do
		local parent = chartSetData.dir
		dict[parent] = (dict[parent] or 0) + 1
	end

	local directoryItems = love.filesystem.getDirectoryItems(basePath)
	for _, name in ipairs(directoryItems) do
		if not ignoredNames[name] then
			local path = basePath .. "/" .. name
			dict[path] = dict[path] or 0
		end
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

---@param path string
---@return number
function CollectionLibrary:getItemIndex(path)
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

return CollectionLibrary
