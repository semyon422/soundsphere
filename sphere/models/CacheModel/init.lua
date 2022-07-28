local aquathread = require("aqua.thread")
local ThreadPool	= require("aqua.thread.ThreadPool")
local Class = require("aqua.util.Class")
local CacheManager = require("sphere.models.CacheModel.CacheManager")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local CacheModel = Class:new()

CacheModel.state = 0
CacheModel.noteChartCount = 0
CacheModel.cachePercent = 0

CacheModel.construct = function(self)
	self.cacheManager = CacheManager:new()
	self.tasks = {}
end

CacheModel.load = function(self)
	CacheDatabase:load()
end

CacheModel.startUpdate = function(self, path, force, callback)
	table.insert(self.tasks, {path, force, callback})
end

CacheModel.stopUpdate = function(self)
	ThreadPool:receive({
		name = "CacheUpdater",
		action = "stop"
	})
end

CacheModel.receive = function(self, event)
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

local isProcessing = false

CacheModel.update = function(self)
	CacheDatabase:update()
	if not isProcessing and #self.tasks > 0 then
		self:process()
	end
end

local updateCacheAsync = aquathread.async(function(path, force)
	local CacheManager = require("sphere.models.CacheModel.CacheManager")
	local cacheManager = CacheManager:new()
	cacheManager:generateCacheFull(path, force)
end)

CacheModel.process = aquathread.coro(function(self)
	if isProcessing then
		return
	end
	isProcessing = true

	local tasks = self.tasks
	local task = table.remove(tasks, 1)
	while task do
		aquathread.pushTask({
			receive = function(event)
				self:receive(event)
			end,
			error = function(message)
				print(message)
			end
		})
		updateCacheAsync(task[1], task[2])

		if task[3] then
			task[3]()
		end

		task = table.remove(tasks, 1)
	end
	-- self.callback()

	isProcessing = false
end)

return CacheModel
