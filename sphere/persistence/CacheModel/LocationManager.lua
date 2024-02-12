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
end

function LocationManager:load()
	self.locations = self.chartRepo:selectChartfileLocations()
	for _, location in ipairs(self.locations) do
		self:mountLocation(location)
	end
end

function LocationManager:unload()
	for _, location in ipairs(self.locations) do
		self.fs.unmount(location.path)
	end
end

---@param location table
function LocationManager:mountLocation(location)
	local path = location.path
	local mp = self:getMountPoint(location)
	if not mp then
		location.status = "direct access"
		location.relative_path = location.path:sub(#self.root + 2)
	elseif self.fs.mount(path, mp, true) then
		location.status = "mounted"
		location.mount_point = mp
	else
		location.status = "errored"
	end
end

---@param location table
---@return string
function LocationManager:getPrefix(location)
	local a, b = location.path:find(self.root)
	if a == 1 then
		return location.path:sub(b + 2)
	end
	return path_util.join(self.prefix, location.id)
end

---@param location table
---@return string?
function LocationManager:getMountPoint(location)
	if not location.path:find(self.root) then
		return path_util.join(self.prefix, location.id)
	end
end

---@param path string OS dependent, absolute
function LocationManager:createLocation(path)
	path = path:gsub("\\", "/")

	local chartRepo = self.chartRepo

	local location = chartRepo:selectChartfileLocation(path)
	if location then
		return
	end

	location = chartRepo:insertChartfileLocation({
		path = path,
		name = path:match("^.+/(.-)$"),
	})

	self:mountLocation(location)
end

return LocationManager
