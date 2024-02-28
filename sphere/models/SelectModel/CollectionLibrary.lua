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

local function process_chartfile_set(dir, tree, location_id)
	local t = tree
	t.count = t.count + 1
	if dir then
		local tpath = {}
		local depth = tree.depth
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
					location_id = location_id,
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

---@param locations_in_collections boolean
function CollectionLibrary:getTree(locations_in_collections)
	local tree = {
		count = 0,
		selected = 1,
		depth = 0,
		path = nil,
		location_id = nil,
		name = "/",
		indexes = {},
		items = {},
	}
	tree.items[1] = tree

	local chartRepo = self.cacheModel.chartRepo
	if not locations_in_collections then
		for _, chartfile_set in ipairs(chartRepo:selectChartfileSetsAtLocation()) do
			process_chartfile_set(chartfile_set.dir, tree)
		end
	else
		local locations = chartRepo:selectLocations()
		for _, location in ipairs(locations) do
			local subtree = {
				count = 0,
				selected = 2,
				depth = 1,
				path = nil,
				location_id = location.id,
				name = location.name,
				indexes = {},
				items = {tree},
			}
			table.insert(tree.items, subtree)
			for _, chartfile_set in ipairs(chartRepo:selectChartfileSetsAtLocation(location.id)) do
				process_chartfile_set(chartfile_set.dir, subtree, location.id)
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

---@param locations_in_collections boolean
function CollectionLibrary:load(locations_in_collections)
	local tree = self:getTree(locations_in_collections)

	self.locations_in_collections = locations_in_collections
	self.root_tree = tree
	self.tree = tree
end

function CollectionLibrary:setPath(path, location_id)
	local tree = self.root_tree
	self.tree = tree

	if not self.locations_in_collections then
		if not path then
			return
		end
	else
		if not path and not location_id then
			return
		elseif location_id then
			local index = table_util.indexof(tree.items, location_id, function(node)
				return node.location_id
			end)
			tree = tree.items[index]
		elseif path then
			return
		end
	end

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
