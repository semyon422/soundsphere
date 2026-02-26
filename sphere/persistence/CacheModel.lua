local thread = require("thread")
local class = require("class")
local physfs = require("physfs")
local pprint = require("pprint")
local ChartviewsRepo = require("sphere.persistence.CacheModel.ChartviewsRepo")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local ComputeDataProvider = require("sphere.persistence.CacheModel.ComputeDataProvider")

local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

---@class sphere.CacheModel
---@operator call: sphere.CacheModel
local CacheModel = class()

---@param difficultyModel sphere.DifficultyModel
function CacheModel:new(difficultyModel)
	self.tasks = {}

	local migrations = {}
	setmetatable(migrations, {__index = function(_, k)
		local data = love.filesystem.read(("sphere/persistence/CacheModel/migrate%s.sql"):format(k))
		return data
	end})

	self.gdb = GameDatabase(migrations)

	self.chartsRepo = ChartsRepo(self.gdb.models)
	self.difftablesRepo = DifftablesRepo(self.gdb.models)

	self.chartviewsRepo = ChartviewsRepo(self.gdb)
	self.locationsRepo = LocationsRepo(self.gdb)
	self.chartfilesRepo = ChartfilesRepo(self.gdb)
	self.cacheStatus = CacheStatus(self.chartfilesRepo, self.chartsRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartsRepo, difficultyModel)
	self.locationManager = LocationManager(
		self.locationsRepo,
		self.chartfilesRepo,
		physfs,
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)

	self.computeDataProvider = ComputeDataProvider(
		self.chartfilesRepo,
		self.chartsRepo,
		self.locationsRepo,
		self.locationManager
	)
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

function CacheModel:computeChartdiffs()
	table.insert(self.tasks, {
		type = "update_chartdiffs",
	})
end

---@param prefer_preview boolean
function CacheModel:computeIncompleteChartdiffs(prefer_preview)
	table.insert(self.tasks, {
		type = "update_incomplete_chartdiffs",
		prefer_preview = prefer_preview,
	})
end

function CacheModel:computeChartplays()
	table.insert(self.tasks, {
		type = "update_chartplays",
	})
end

---@param path string
---@param location_id number
function CacheModel:startUpdateAsync(path, location_id)
	local c = coroutine.running()
	table.insert(self.tasks, {
		type = "update_cache",
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
	pprint(task)
	local CacheManager = require("sphere.persistence.CacheModel.CacheManager")
	local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")

	local gdb = GameDatabase()
	gdb:load()

	local cacheManager = CacheManager(gdb)

	if task.type == "update_cache" then
		cacheManager:computeCacheLocation(task.path, task.location_id)
	elseif task.type == "update_chartdiffs" then
		cacheManager:computeChartdiffs()
	elseif task.type == "update_incomplete_chartdiffs" then
		cacheManager:computeIncompleteChartdiffs(task.prefer_preview)
	elseif task.type == "update_chartplays" then
		cacheManager:computeChartplays()
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
		local callback = task.callback
		task.callback = nil

		self.gdb:unload()
		runTaskAsync(task)
		self.gdb:load()

		if callback then
			callback()
		end

		task = table.remove(tasks, 1)
	end

	self.isProcessing = false
end

CacheModel.process = thread.coro(CacheModel.process)

return CacheModel
