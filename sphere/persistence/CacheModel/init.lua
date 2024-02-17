local thread = require("thread")
local class = require("class")
local physfs = require("physfs")
local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local ChartsDatabase = require("sphere.persistence.CacheModel.ChartsDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
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
	self.locationManager = LocationManager(
		self.chartRepo,
		physfs,
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)
end

function CacheModel:load()
	thread.shared.cache = {
		state = 0,
		chartfiles_count = 0,
		chartfiles_current = 0,
	}
	self.shared = thread.shared.cache

	self.cdb:load()
	self.cacheStatus:update()

	self.locationManager:load()
	self.locationManager:createLocation({
		path = "userdata/charts",
		name = "soundsphere",
		is_relative = true,
		is_internal = true,
	})
end

function CacheModel:unload()
	self.cdb:unload()
end

---@param path string
---@param location_id number
function CacheModel:startUpdate(path, location_id)
	table.insert(self.tasks, {
		path = path,
		location_id = location_id,
	})
end

---@param path string
---@param location_id number
function CacheModel:startUpdateAsync(path, location_id)
	local c = coroutine.running()
	table.insert(self.tasks, {
		path = path,
		location_id = location_id,
		callback = function()
			coroutine.resume(c)
		end
	})
	coroutine.yield()
end

function CacheModel:stopUpdate()
	self.shared.stop = true
end

function CacheModel:update()
	if not self.isProcessing and #self.tasks > 0 then
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

function CacheModel:process()
	if self.isProcessing then
		return
	end
	self.isProcessing = true

	local tasks = self.tasks
	local task = table.remove(tasks, 1)
	while task do
		local location = self.chartRepo:selectLocationById(task.location_id)
		local prefix = self.locationManager:getPrefix(location)

		self.cdb:unload()
		updateCacheAsync(task.path, task.location_id, prefix)
		self.cdb:load()

		if task.callback then
			task.callback()
		end

		task = table.remove(tasks, 1)
	end

	self.isProcessing = false
end

CacheModel.process = thread.coro(CacheModel.process)

return CacheModel
