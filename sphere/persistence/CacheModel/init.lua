local thread = require("thread")
local class = require("class")
local physfs = require("physfs")
local path_util = require("path_util")
local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local OldScoresMigrator = require("sphere.persistence.CacheModel.OldScoresMigrator")
local DifficultyModel = require("sphere.models.DifficultyModel")

---@class sphere.CacheModel
---@operator call: sphere.CacheModel
local CacheModel = class()

function CacheModel:new()
	self.tasks = {}

	local migrations = {}
	setmetatable(migrations, {__index = function(_, k)
		local data = love.filesystem.read(("sphere/persistence/CacheModel/migrate%s.sql"):format(k))
		return data
	end})
	migrations[1] = function()
		self.oldScoresMigrator:migrate()
	end

	self.gdb = GameDatabase(migrations)
	self.cacheDatabase = CacheDatabase(self.gdb)
	self.chartRepo = ChartRepo(self.gdb)
	self.cacheStatus = CacheStatus(self.chartRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartRepo, DifficultyModel)
	self.locationManager = LocationManager(
		self.chartRepo,
		physfs,
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)

	self.oldScoresMigrator = OldScoresMigrator(self.chartRepo)
end

function CacheModel:load()
	thread.shared.cache = {
		state = 0,
		chartfiles_count = 0,
		chartfiles_current = 0,
	}
	self.shared = thread.shared.cache

	self.gdb:load()
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
	self.gdb:unload()
end

---@param path string
---@param location_id number
function CacheModel:startUpdate(path, location_id)
	table.insert(self.tasks, {
		type = "update_cache",
		path = path,
		location_id = location_id,
	})
end

function CacheModel:computeScoresWithMissingChartdiffs()
	table.insert(self.tasks, {
		type = "update_scores_chartdiffs",
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

function CacheModel:stopTask()
	self.shared.stop = true
end

function CacheModel:update()
	if not self.isProcessing and #self.tasks > 0 then
		self:process()
	end
end

local runTaskAsync = thread.async(function(task)
	print(require("inspect")(task))
	local CacheManager = require("sphere.persistence.CacheModel.CacheManager")
	local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")

	local gdb = GameDatabase()
	gdb:load()

	local cacheManager = CacheManager(gdb)

	if task.type == "update_cache" then
		cacheManager:generateCacheFull(task.path, task.location_id, task.location_prefix)
	elseif task.type == "update_scores_chartdiffs" then
		cacheManager:computeScoresWithMissingChartdiffs()
	end

	gdb:unload()
end)

function CacheModel:process()
	if self.isProcessing then
		return
	end
	self.isProcessing = true

	local tasks = self.tasks
	local task = table.remove(tasks, 1)
	while task do
		if task.type == "update_cache" then
			local location = self.chartRepo:selectLocationById(task.location_id)
			local prefix = self.locationManager:getPrefix(location)
			task.location_prefix = prefix
		end

		self.gdb:unload()
		runTaskAsync(task)
		self.gdb:load()

		if task.callback then
			task.callback()
		end

		task = table.remove(tasks, 1)
	end

	self.isProcessing = false
end

CacheModel.process = thread.coro(CacheModel.process)

return CacheModel
