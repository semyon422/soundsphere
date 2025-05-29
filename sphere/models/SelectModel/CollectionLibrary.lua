local class = require("class")
local string_util = require("string_util")
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
		for i, k in ipairs(string_util.split(dir, "/")) do
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

	local chartfilesRepo = self.cacheModel.chartfilesRepo
	local locationsRepo = self.cacheModel.locationsRepo
	if not locations_in_collections then
		for _, chartfile_set in ipairs(chartfilesRepo:selectChartfileSets()) do
			process_chartfile_set(chartfile_set.dir, tree)
		end
	else
		local locations = locationsRepo:selectLocations()
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
			for _, chartfile_set in ipairs(chartfilesRepo:selectChartfileSetsAtLocation(location.id)) do
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
	self.tree = self.root_tree
	if self.locations_in_collections then
		return self:setPathLic(path, location_id)
	end
	return self:setPathP(path)
end

function CollectionLibrary:setPathLic(path, location_id)
	local tree = self.tree

	if not location_id then
		return
	end

	local index = table_util.indexof(tree.items, location_id, function(node)
		return node.location_id
	end)
	tree.selected = index or 1

	if not path then
		return
	end

	self.tree = tree.items[tree.selected]

	self:setPathP(path)
end

function CollectionLibrary:setPathP(path)
	if not path then
		return
	end

	local tree = self.tree

	local keys = string_util.split(path, "/")
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
