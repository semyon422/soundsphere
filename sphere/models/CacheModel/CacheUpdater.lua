local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")

local CacheUpdater = Class:new()

CacheUpdater.construct = function(self)
	self.observable = Observable:new()
end

CacheUpdater.load = function(self)
	ThreadPool.observable:add(self)
end

CacheUpdater.unload = function(self)
	ThreadPool.observable:remove(self)
end

CacheUpdater.send = function(self, event)
	return self.observable:send(event)
end

CacheUpdater.receive = function(self, event)
	if event.name == "CacheProgress" then
		if event.state == 3 then
			self.cacheManager:select()
			self.isUpdating = false
		end
		self:send(event)
	end
end

CacheUpdater.stop = function(self)
	ThreadPool:receive({
		name = "CacheUpdater",
		action = "stop"
	})
end

CacheUpdater.start = function(self, path, force)
	if not self.isUpdating then
		self.isUpdating = true
		return ThreadPool:execute(
			[[
				local CacheDatabase	= require("sphere.models.CacheModel.CacheDatabase")
				local CacheManager	= require("sphere.models.CacheModel.CacheManager")

				local cacheManager = CacheManager:new()

				cacheManager:generateCacheFull(...)
			]],
			{path, force}
		)
	end
end

return CacheUpdater
