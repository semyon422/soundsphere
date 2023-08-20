local thread = require("thread")
local class = require("class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.models.CacheModel.ChartRepo")

---@class sphere.CacheModel
---@operator call: sphere.CacheModel
local CacheModel = class()

function CacheModel:new()
	self.tasks = {}
end

function CacheModel:load()
	thread.shared.cache = {
		state = 0,
		noteChartCount = 0,
		cachePercent = 0,
	}
	self.shared = thread.shared.cache

	self.cacheDatabase = CacheDatabase()
	self.cacheDatabase:load()

	self.chartRepo = ChartRepo()
	self.chartRepo:load()
end

---@param path string
---@param force boolean?
---@param callback function?
function CacheModel:startUpdate(path, force, callback)
	table.insert(self.tasks, {path, force, callback})
end

function CacheModel:stopUpdate()
	self.shared.stop = true
end

local isProcessing = false

function CacheModel:update()
	self.cacheDatabase:update()
	if not isProcessing and #self.tasks > 0 then
		self:process()
	end
end

local updateCacheAsync = thread.async(function(path, force)
	local CacheManager = require("sphere.models.CacheModel.CacheManager")
	local cacheManager = CacheManager()
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
