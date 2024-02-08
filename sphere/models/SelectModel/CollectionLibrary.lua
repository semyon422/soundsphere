local class = require("class")

---@class sphere.CollectionLibrary
---@operator call: sphere.CollectionLibrary
local CollectionLibrary = class()

local ignoredNames = {
	".keep",
}
for i = 1, #ignoredNames do
	ignoredNames[ignoredNames[i]] = true
end

---@param cacheModel sphere.CacheModel
---@param configModel sphere.ConfigModel
function CollectionLibrary:new(cacheModel, configModel)
	self.cacheModel = cacheModel
	self.configModel = configModel
end

function CollectionLibrary:load()
	self.config = self.configModel.configs.select
	local collectionPath = self.config.collection

	local dict = {}
	for _, chartfile_set in ipairs(self.cacheModel.chartRepo:selectChartfileSetsAtPath()) do
		local dir = chartfile_set.dir or "."
		dict[dir] = (dict[dir] or 0) + 1
	end

	local items = {{
		path = "",
		shortPath = "",
		name = "/",
		count = 0,
	}}
	for path, count in pairs(dict) do
		local dir, name = path:match("^(.+)/(.-)$")
		local collection = {
			path = path,
			shortPath = dir or "",
			name = name or path,
			count = count,
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
