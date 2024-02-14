local class = require("class")
local path_util = require("path_util")

---@class sphere.LocationManager
---@operator call: sphere.LocationManager
local LocationManager = class()

---@param chartRepo sphere.ChartRepo
---@param fs love.filesystem
---@param root string OS dependent, absolute
---@param prefix string
function LocationManager:new(chartRepo, fs, root, prefix)
	self.chartRepo = chartRepo
	self.fs = fs
	self.root = root
	self.prefix = prefix
	self.mounted = {}
end

function LocationManager:load()
	self.locations = self.chartRepo:selectChartfileLocations()
	for _, location in ipairs(self.locations) do
		self:mountLocation(location)
	end
end

function LocationManager:unload()
	for _, location in ipairs(self.locations) do
		if self.mounted[location.id] then
			self.fs.unmount(location.path)
			self.mounted[location.id] = nil
		end
	end
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

---@param loc table
function LocationManager:createLocation(loc)
	loc.path = loc.path:gsub("\\", "/")

	local a, b = loc.path:find(self.root)
	if a == 1 then
		loc.path = loc.path:sub(b + 2)
		loc.is_relative = true
	end

	if not loc.name then
		loc.name = loc.path:match("^.+/(.-)$") or loc.path
	end

	local chartRepo = self.chartRepo

	local location = chartRepo:selectChartfileLocation(loc.path)
	if location then
		return
	end

	loc.is_relative = not not loc.is_relative
	loc.is_internal = not not loc.is_internal
	chartRepo:insertChartfileLocation(loc)

	self:load()
end

function LocationManager:deleteCharts(location_id)
	self.chartRepo:deleteChartfileSets({
		location_id = assert(location_id),
	})
end

function LocationManager:deleteLocation(location_id)
	self.chartRepo:deleteLocation(location_id)
end

return LocationManager
