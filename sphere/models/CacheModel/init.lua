local Class = require("aqua.util.Class")
local CacheUpdater = require("sphere.models.CacheModel.CacheUpdater")
local CacheManager = require("sphere.models.CacheModel.CacheManager")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local CacheModel = Class:new()

CacheModel.construct = function(self)
	self.cacheUpdater = CacheUpdater:new()
	self.cacheManager = CacheManager:new()
end

CacheModel.load = function(self)
	self.cacheUpdater.cacheManager = self.cacheManager
	CacheDatabase:load()
end

CacheModel.unload = function(self) end

CacheModel.startUpdate = function(self, path, force)
	self.cacheUpdater:start(path, force)
end

CacheModel.stopUpdate = function(self)
	self.cacheUpdater:stop()
end

CacheModel.update = function(self)
	CacheDatabase:update()
end

return CacheModel
