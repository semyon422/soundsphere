local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")

local CacheUpdater = Class:new()

CacheUpdater.state = 0
CacheUpdater.noteChartCount = 0
CacheUpdater.cachePercent = 0

CacheUpdater.receive = function(self, event)
	if event.name ~= "CacheProgress" then
		return
	end

	if event.state == 1 then
		self.noteChartCount = event.noteChartCount
	elseif event.state == 2 then
		self.cachePercent = event.cachePercent
	elseif event.state == 3 then
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
	if self.isUpdating then
		return
	end
	self.isUpdating = true
	return ThreadPool:execute({
		f = function(path, force)
			local CacheManager = require("sphere.models.CacheModel.CacheManager")
			local cacheManager = CacheManager:new()
			cacheManager:generateCacheFull(path, force)
		end,
		params = {path, force},
		receive = function(event)
			self:receive(event)
		end,
		error = function(message)
			print(message)
		end
	})
end

return CacheUpdater
