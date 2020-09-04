local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local CacheUpdater = require("sphere.models.CacheModel.CacheUpdater")
local CacheManager = require("sphere.models.CacheModel.CacheManager")

local CacheModel = Class:new()

CacheModel.construct = function(self)
	self.observable = Observable:new()
	self.cacheUpdater = CacheUpdater:new()
	self.cacheManager = CacheManager:new()
end

CacheModel.load = function(self)
	self.cacheUpdater.cacheManager = self.cacheManager
	self.cacheManager:select()
	self.cacheUpdater.observable:add(self)
	self.cacheUpdater:load()
end

CacheModel.unload = function(self)
	self.cacheUpdater.observable:remove(self)
	self.cacheUpdater:unload()
end

CacheModel.startUpdate = function(self, path, force)
	self.cacheUpdater:start(path, force)
end

CacheModel.stopUpdate = function(self)
	self.cacheUpdater:stop()
end

CacheModel.receive = function(self, event)
	self.observable:send(event)
end

return CacheModel
