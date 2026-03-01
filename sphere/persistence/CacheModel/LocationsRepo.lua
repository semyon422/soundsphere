local class = require("class")

---@class sphere.LocationsRepo
---@operator call: sphere.LocationsRepo
local LocationsRepo = class()

---@param models sphere.CacheModelModels
function LocationsRepo:new(models)
	self.models = models
end

---@return sphere.Location[]
function LocationsRepo:selectLocations()
	return self.models.locations:select()
end

---@param path string
---@return sphere.Location?
function LocationsRepo:selectLocation(path)
	return self.models.locations:find({path = assert(path)})
end

---@param id integer
---@return sphere.Location?
function LocationsRepo:selectLocationById(id)
	return self.models.locations:find({id = assert(id)})
end

---@param location sphere.Location
---@return sphere.Location
function LocationsRepo:insertLocation(location)
	return self.models.locations:create(location)
end

---@param location sphere.Location
---@return sphere.Location?
function LocationsRepo:updateLocation(location)
	return self.models.locations:update(location, {id = location.id})
end

---@param location_id integer
function LocationsRepo:deleteLocation(location_id)
	self.models.locations:delete({id = assert(location_id)})
end

return LocationsRepo
