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
		path = nil,
		items = {},
	}

	for _, chartfile_set in ipairs(self.cacheModel.chartRepo:selectChartfileSetsAtPath()) do
		local dir = chartfile_set.dir
		local t = tree
		t.count = t.count + 1
		if dir then
			local tpath = {}
			for i, k in ipairs(dir:split("/")) do
				tpath[i] = k
				t.items[k] = t.items[k] or {
					count = 0,
					path = path_util.join(unpack(tpath)),
					items = {},
				}
				t = t.items[k]
				t.count = t.count + 1
			end
		end
	end

	return tree
end

function CollectionLibrary:load()
	self.config = self.configModel.configs.select
	local collectionPath = self.config.collection

	local tree = self:getTree()

	local upper_tree
	if self.dir then
		for _, k in ipairs(self.dir:split("/")) do
			upper_tree = tree
			tree = tree.items[k]
		end
	end

	local items = {}
	self.items = items

	for k, subtree in dpairs(tree.items) do
		local collection = {
			path = subtree.path,
			shortPath = "",
			-- shortPath = subtree.path,
			name = k,
			count = subtree.count,
		}
		items[#items + 1] = collection
		if k == collectionPath then
			self.collection = collection
		end
	end
	table.sort(items, function(a, b) return a.path < b.path end)

	if not self.dir then
		table.insert(items, 1, {
			path = nil,
			shortPath = "",
			name = "/",
			count = tree.count,
		})
	else
		table.insert(items, 1, {
			path = upper_tree.path,
			shortPath = upper_tree.path,
			name = "..",
			count = upper_tree.count,
		})
		table.insert(items, 2, {
			path = tree.path,
			shortPath = tree.path,
			name = ".",
			count = tree.count,
		})
	end

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
