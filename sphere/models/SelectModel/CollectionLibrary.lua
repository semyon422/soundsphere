local class = require("class")
local dpairs = require("dpairs")
local table_util = require("table_util")
local path_util = require("path_util")

---@class sphere.CollectionLibrary
---@operator call: sphere.CollectionLibrary
local CollectionLibrary = class()

-- CollectionLibrary.dir = "10key"

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

function CollectionLibrary:getTree()
	local tree = {
		count = 0,
		selected = 1,
		depth = 0,
		path = nil,
		name = "/",
		indexes = {},
		items = {},
	}
	tree.items[1] = tree

	for _, chartfile_set in ipairs(self.cacheModel.chartRepo:selectChartfileSetsAtPath()) do
		local dir = chartfile_set.dir
		local t = tree
		t.count = t.count + 1
		if dir then
			local tpath = {}
			local depth = 0
			for i, k in ipairs(dir:split("/")) do
				depth = depth + 1
				tpath[i] = k
				local index = t.indexes[k]
				local item = t.items[index]
				if not item then
					item = {
						count = 0,
						selected = 1,
						depth = depth,
						path = path_util.join(unpack(tpath)),
						name = k,
						indexes = {},
						items = {t},
					}
					item.items[2] = item
					index = #t.items + 1
					t.indexes[k] = index
					t.items[index] = item
				end
				t = item
				t.count = t.count + 1
			end
		end
	end

	return tree
end

function CollectionLibrary:enter(tree)
	self.tree = tree
	self.items = tree.items
end

function CollectionLibrary:load()
	self.config = self.configModel.configs.select
	local collectionPath = self.config.collection

	local tree = self:getTree()

	local items = {}
	self.tree = tree
	self.items = tree.items

	self.collection = self.collection or items[1]
end

---@param path string
---@return number
function CollectionLibrary:indexof(path)
	return table_util.indexof(self.items, path, function(c)
		return c.path
	end) or 1
end

return CollectionLibrary
