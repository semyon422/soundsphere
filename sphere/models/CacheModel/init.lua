local thread = require("thread")
local Class = require("Class")
local CacheManager = require("sphere.models.CacheModel.CacheManager")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.models.CacheModel.ChartRepo")

local CacheModel = Class:new()

CacheModel.construct = function(self)
	self.cacheManager = CacheManager:new()
	self.tasks = {}
end

CacheModel.load = function(self)
	CacheDatabase:load()
	thread.shared.cache = {
		state = 0,
		noteChartCount = 0,
		cachePercent = 0,
	}
	self.shared = thread.shared.cache
	self.chartRepo = ChartRepo:new()
	self.chartRepo:load()
end

CacheModel.startUpdate = function(self, path, force, callback)
	table.insert(self.tasks, {path, force, callback})
end

CacheModel.stopUpdate = function(self)
	self.shared.stop = true
end

local isProcessing = false

CacheModel.update = function(self)
	CacheDatabase:update()
	if not isProcessing and #self.tasks > 0 then
		self:process()
	end
end

local updateCacheAsync = thread.async(function(path, force)
	local CacheManager = require("sphere.models.CacheModel.CacheManager")
	local cacheManager = CacheManager:new()
	cacheManager:generateCacheFull(path, force)
end)

CacheModel.process = thread.coro(function(self)
	if isProcessing then
		return
	end
	isProcessing = true

	local tasks = self.tasks
	local task = table.remove(tasks, 1)
	while task do
		thread.pushTask({error = print})
		updateCacheAsync(task[1], task[2])

		if task[3] then
			task[3]()
		end

		task = table.remove(tasks, 1)
	end

	isProcessing = false
end)

return CacheModel
