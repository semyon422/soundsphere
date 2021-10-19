local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")

local CacheUpdater = Class:new()

CacheUpdater.state = 0
CacheUpdater.noteChartCount = 0
CacheUpdater.cachePercent = 0

CacheUpdater.construct = function(self)
	self.observable = Observable:new()
end

CacheUpdater.load = function(self)
	ThreadPool.observable:add(self)
end

CacheUpdater.unload = function(self)
	ThreadPool.observable:remove(self)
end

CacheUpdater.receive = function(self, event)
	if event.name ~= "CacheProgress" then
		return
	end

	if event.state == 1 then
		self.noteChartCount = event.noteChartCount
	elseif event.state == 2 then
		self.cachePercent = event.cachePercent
	elseif event.state == 3 then
		self.cacheManager:select()
		self.isUpdating = false
	end
	self.state = event.state
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
			function(...)
				local CacheDatabase	= require("sphere.models.CacheModel.CacheDatabase")
				local CacheManager	= require("sphere.models.CacheModel.CacheManager")

				local cacheManager = CacheManager:new()

				cacheManager:generateCacheFull(...)
			end,
			{path, force}
		)
	end
end

return CacheUpdater
