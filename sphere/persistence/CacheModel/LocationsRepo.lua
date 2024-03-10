local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.LocationsRepo
---@operator call: sphere.LocationsRepo
local LocationsRepo = class()

---@param gdb sphere.GameDatabase
function LocationsRepo:new(gdb)
	self.models = gdb.models
end

---@return table
function LocationsRepo:selectLocations()
	return self.models.locations:select()
end

---@param path string
---@return table?
function LocationsRepo:selectLocation(path)
	return self.models.locations:find({path = assert(path)})
end

---@param id number
---@return table?
function LocationsRepo:selectLocationById(id)
	return self.models.locations:find({id = assert(id)})
end

---@param location table
---@return table
function LocationsRepo:insertLocation(location)
	return self.models.locations:create(location)
end

---@param location table
---@return table?
function LocationsRepo:updateLocation(location)
	return self.models.locations:update(location, {id = location.id})
end

---@param location_id number
function LocationsRepo:deleteLocation(location_id)
	self.models.locations:delete({id = assert(location_id)})
end

return LocationsRepo
