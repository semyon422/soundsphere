local physfs = require("physfs")
local class = require("class")

---@class sphere.MountModel
---@operator call: sphere.MountModel
local MountModel = class()

---@param cacheModel sphere.CacheModel
function MountModel:new(cacheModel)
	self.cacheModel = cacheModel
end

function MountModel:load()
	self.status = {}
	local cf_locations = self.cacheModel.chartRepo:selectChartfileLocations()
	self.cf_locations = cf_locations
	for _, cf_location in ipairs(cf_locations) do
		self:mountLocation(cf_location)
	end
end

function MountModel:unload()
	for path, status in pairs(self.status) do
		if status == "mounted" then
			physfs.unmount(path)
		end
	end
end

---@param cf_location table
function MountModel:mountLocation(cf_location)
	local path = cf_location.path
	local status = "mounted"
	if not physfs.mount(path, self:getMountPoint(cf_location), true) then
		status = physfs.getLastError()
	end
	self.status[path] = status
end

---@param cf_location table
---@return string
function MountModel:getMountPoint(cf_location)
	return "mounted_charts/" .. cf_location.id
end

---@param path string
function MountModel:createLocation(path)
	path = path:gsub("\\", "/")

	local chartRepo = self.cacheModel.chartRepo

	local cf_location = chartRepo:selectChartfileLocation(path)
	if cf_location then
		return
	end

	cf_location = chartRepo:insertChartfileLocation({
		path = path,
		name = path:match("^.+/(.-)$"),
	})

	self:mountLocation(cf_location)
end

---@param path string
---@return string?
function MountModel:getRealPath(path)
	local realDirectory = love.filesystem.getRealDirectory(path)
	if not realDirectory then
		return
	end

	local cf_location = self.cacheModel.chartRepo:selectChartfileLocation(path)
	if not cf_location then
		return realDirectory .. "/" .. path
	end

	return cf_location.path .. "/" .. path
end

return MountModel
