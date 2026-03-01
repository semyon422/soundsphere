local class = require("class")
local path_util = require("path_util")
local table_util = require("table_util")

---@class rizu.library.Locations
---@operator call: rizu.library.Locations
local Locations = class()

---@param locationsRepo rizu.library.LocationsRepo
---@param chartfilesRepo rizu.library.ChartfilesRepo
---@param fs fs.IFilesystem
---@param root string OS dependent, absolute
---@param prefix string
function Locations:new(locationsRepo, chartfilesRepo, fs, root, prefix)
	self.locationsRepo = locationsRepo
	self.chartfilesRepo = chartfilesRepo
	self.fs = fs
	self.root = root
	self.prefix = prefix
	self.mounted = {}
	---@type sphere.Location[]
	self.locations = {}
	---@type sphere.Location?
	self.selected_loc = nil
end

function Locations:load()
	self:createDefaultLocation()
	self:selectLocations()
	for _, location in ipairs(self.locations) do
		self:mountLocation(location)
	end
	self:selectLocation(1)
end

function Locations:unload()
	for _, location in ipairs(self.locations) do
		self:unmountLocation(location)
	end
end

function Locations:selectLocations()
	self.locations = self.locationsRepo:selectLocations()
end

---@param id number
function Locations:selectLocation(id)
	self.selected_id = id
	local index = table_util.indexof(self.locations, self.selected_id, function(loc)
		return loc.id
	end)

	if not index then
		self.selected_id = 1
		index = 1
	end

	self.selected_loc = self.locations[index]

	local chartfilesRepo = self.chartfilesRepo

	self.location_info = {
		chartfile_sets = chartfilesRepo:countChartfileSets({location_id = id}),
		chartfiles = chartfilesRepo:countChartfiles({location_id = id}),
		hashed_chartfiles = chartfilesRepo:countChartfiles({
			location_id = id,
			hash__isnotnull = true,
		}),
	}
end

---@param location sphere.Location
function Locations:unmountLocation(location)
	if not self.mounted[location.id] then
		return
	end
	self.fs:unmount(location.path)
	self.mounted[location.id] = nil
end

---@param location sphere.Location
function Locations:mountLocation(location)
	local path = location.path
	if location.is_relative then
		location.status = "direct access"
		return
	end
	if self.mounted[location.id] then
		location.status = "mounted"
		return
	end
	local mp = path_util.join(self.prefix, location.id)
	if self.fs:mount(path, mp, true) then
		self.mounted[location.id] = true
		location.status = "mounted"
		return
	end
	location.status = "errored"
end

---@param location sphere.Location
---@return string
function Locations:getPrefix(location)
	if location.is_relative then
		return location.path
	end
	return path_util.join(self.prefix, location.id)
end

function Locations:createDefaultLocation()
	local loc = {
		path = "userdata/charts",
		name = "game",
		is_relative = true,
		is_internal = true,
	}

	local locationsRepo = self.locationsRepo

	local location = locationsRepo:selectLocation(loc.path)
	if location then
		return
	end

	locationsRepo:insertLocation(loc)
end

---@param path string
function Locations:updateLocationPath(path)
	local loc = self.selected_loc
	if loc.is_internal then
		return
	end

	self:unmountLocation(loc)

	loc.path = path:gsub("\\", "/")
	loc.is_relative = false

	local a, b = path:find(self.root)
	if a == 1 then
		loc.path = loc.path:sub(b + 2)
		loc.is_relative = true
	end

	self.locationsRepo:updateLocation(loc)
	self:mountLocation(loc)
end

function Locations:deleteCharts(location_id)
	self.chartfilesRepo:deleteChartfileSets({
		location_id = assert(location_id),
	})
end

function Locations:deleteLocation(location_id)
	self.locationsRepo:deleteLocation(location_id)
end

return Locations
