local thread = require("thread")
local class = require("class")
local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local ChartsDatabase = require("sphere.persistence.CacheModel.ChartsDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local DifficultyModel = require("sphere.models.DifficultyModel")

---@class sphere.CacheModel
---@operator call: sphere.CacheModel
local CacheModel = class()

function CacheModel:new()
	self.tasks = {}

	self.cdb = ChartsDatabase()
	self.cacheDatabase = CacheDatabase(self.cdb)
	self.chartRepo = ChartRepo(self.cdb)
	self.cacheStatus = CacheStatus(self.chartRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartRepo, DifficultyModel)
end

function CacheModel:load()
	thread.shared.cache = {
		state = 0,
		noteChartCount = 0,
		cachePercent = 0,
	}
	self.shared = thread.shared.cache

	self.cdb:load()
	self.cacheStatus:update()
end

function CacheModel:unload()
	self.cdb:unload()
end

---@param args string
---@param callback function?
function CacheModel:startUpdate(args, callback)
	table.insert(self.tasks, {args, callback})
end

function CacheModel:stopUpdate()
	self.shared.stop = true
end

local isProcessing = false

function CacheModel:update()
	if not isProcessing and #self.tasks > 0 then
		self:process()
	end
end

local updateCacheAsync = thread.async(function(path, location_id, location_prefix)
	print(path, location_id, location_prefix)
	local CacheManager = require("sphere.persistence.CacheModel.CacheManager")
	local ChartsDatabase = require("sphere.persistence.CacheModel.ChartsDatabase")

	local cdb = ChartsDatabase()
	cdb:load()

	local cacheManager = CacheManager(cdb)
	cacheManager:generateCacheFull(path, location_id, location_prefix)

	cdb:unload()
end)

CacheModel.process = thread.coro(function(self)
	if isProcessing then
		return
	end
	isProcessing = true

	local tasks = self.tasks
	local task = table.remove(tasks, 1)
	while task do
		updateCacheAsync(unpack(task[1]))

		if task[2] then
			task[2]()
		end

		task = table.remove(tasks, 1)
	end

	isProcessing = false
end)

return CacheModel
