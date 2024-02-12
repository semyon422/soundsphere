local class = require("class")
local dpairs = require("dpairs")
local table_util = require("table_util")
local path_util = require("path_util")

---@class sphere.CollectionLibrary
---@operator call: sphere.CollectionLibrary
local CollectionLibrary = class()

---@param cacheModel sphere.CacheModel
function CollectionLibrary:new(cacheModel)
	self.cacheModel = cacheModel
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
						selected = 2,
						depth = depth,
						path = path_util.join(unpack(tpath)),
						name = k,
						indexes = {},
						items = {t},
					}
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

function CollectionLibrary:enter()
	local node = self.tree.items[self.tree.selected]
	if #node.items > 1 then
		self.tree = node
	end
end

function CollectionLibrary:load()
	local tree = self:getTree()

	self.root_tree = tree
	self.tree = tree
end

function CollectionLibrary:setPath(path)
	if not path then
		self.tree = self.root_tree
		return
	end
	local tree = self.root_tree

	local keys = path:split("/")
	for i = 1, #keys do
		local index = tree.indexes[keys[i]]
		if index then
			tree.selected = index
			if i < #keys then
				tree = tree.items[index]
				self.tree = tree
			end
		else
			return
		end
	end
end

return CollectionLibrary
