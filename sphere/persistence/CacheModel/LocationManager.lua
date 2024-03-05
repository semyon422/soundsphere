local class = require("class")
local path_util = require("path_util")
local table_util = require("table_util")

---@class sphere.LocationManager
---@operator call: sphere.LocationManager
local LocationManager = class()

---@param locationsRepo sphere.LocationsRepo
---@param chartfilesRepo sphere.ChartfilesRepo
---@param fs love.filesystem
---@param root string OS dependent, absolute
---@param prefix string
function LocationManager:new(locationsRepo, chartfilesRepo, fs, root, prefix)
	self.locationsRepo = locationsRepo
	self.chartfilesRepo = chartfilesRepo
	self.fs = fs
	self.root = root
	self.prefix = prefix
	self.mounted = {}
end

function LocationManager:load()
	self:createDefaultLocation()
	self:selectLocations()
	for _, location in ipairs(self.locations) do
		self:mountLocation(location)
	end
	self:selectLocation(1)
end

function LocationManager:unload()
	for _, location in ipairs(self.locations) do
		self:unmountLocation(location)
	end
end

function LocationManager:selectLocations()
	self.locations = self.locationsRepo:selectLocations()
end

---@param id number
function LocationManager:selectLocation(id)
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

---@param location table
function LocationManager:unmountLocation(location)
	if not self.mounted[location.id] then
		return
	end
	self.fs.unmount(location.path)
	self.mounted[location.id] = nil
end

---@param location table
function LocationManager:mountLocation(location)
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
	if self.fs.mount(path, mp, true) then
		self.mounted[location.id] = true
		location.status = "mounted"
		return
	end
	location.status = "errored"
end

---@param location table
---@return string
function LocationManager:getPrefix(location)
	if location.is_relative then
		return location.path
	end
	return path_util.join(self.prefix, location.id)
end

function LocationManager:createDefaultLocation()
	local loc = {
		path = "userdata/charts",
		name = "soundsphere",
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
function LocationManager:updateLocationPath(path)
	local loc = self.selected_loc
	if loc.is_internal then
		return
	end

	self:unmountLocation(loc)

	loc.path = path:gsub("\\", "/")

	local a, b = path:find(self.root)
	if a == 1 then
		loc.path = loc.path:sub(b + 2)
		loc.is_relative = true
	end

	self.locationsRepo:updateLocation(loc)
	self:mountLocation(loc)
end

function LocationManager:deleteCharts(location_id)
	self.chartfilesRepo:deleteChartfileSets({
		location_id = assert(location_id),
	})
end

function LocationManager:deleteLocation(location_id)
	self.locationsRepo:deleteLocation(location_id)
end

return LocationManager
