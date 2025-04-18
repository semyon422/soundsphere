local thread = require("thread")
local class = require("class")
local physfs = require("physfs")
local path_util = require("path_util")
local md5 = require("md5")
local types = require("sea.shared.types")
local ChartviewsRepo = require("sphere.persistence.CacheModel.ChartviewsRepo")
local ChartdiffsRepo = require("sphere.persistence.CacheModel.ChartdiffsRepo")
local ChartmetasRepo = require("sphere.persistence.CacheModel.ChartmetasRepo")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local ChartplaysRepo = require("sphere.persistence.CacheModel.ChartplaysRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")

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
	self.chartviewsRepo = ChartviewsRepo(self.gdb)
	self.chartdiffsRepo = ChartdiffsRepo(self.gdb, difficultyModel.registry.fields)
	self.chartmetasRepo = ChartmetasRepo(self.gdb)
	self.locationsRepo = LocationsRepo(self.gdb)
	self.chartplaysRepo = ChartplaysRepo(self.gdb)
	self.chartfilesRepo = ChartfilesRepo(self.gdb)
	self.cacheStatus = CacheStatus(self.chartfilesRepo, self.chartmetasRepo, self.chartdiffsRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartdiffsRepo, difficultyModel)
	self.locationManager = LocationManager(
		self.locationsRepo,
		self.chartfilesRepo,
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
	print(require("inspect")(task))
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

---@param hash string
---@return {name: string, data: string}?
---@return string?
function CacheModel:getChartfileData(hash)
	if not types.md5hash(hash) then
		return nil, "invalid hash"
	end

	local chartfile = self.chartfilesRepo:selectChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found"
	end

	local chartfile_set = self.chartfilesRepo:selectChartfileSetById(chartfile.set_id)
	if not chartfile_set then
		return nil, "chartfile_set not found"
	end

	local location = self.locationsRepo:selectLocationById(chartfile_set.location_id)
	if not location then
		return nil, "location not found"
	end

	local prefix = self.locationManager:getPrefix(location)
	local path = path_util.join(prefix, chartfile_set.dir, chartfile_set.name, chartfile.name)

	local data = love.filesystem.read(path)
	if not data then
		return nil, "file not found"
	end

	if md5.sumhexa(data) ~= hash then
		return nil, "hash mismatch"
	end

	return {
		name = chartfile.name,
		data = data,
	}
end

---@param replay_hash string
---@return string?
---@return string?
function CacheModel:getReplayData(replay_hash)
	if not types.md5hash(replay_hash) then
		return nil, "invalid hash"
	end

	local chartplay = self.chartplaysRepo:getChartplayByReplayHash(replay_hash)
	if not chartplay then
		return nil, "chartplay not found"
	end

	local data = love.filesystem.read("userdata/replays/" .. replay_hash)
	if not data then
		return nil, "replay file not found"
	end

	if md5.sumhexa(data) ~= replay_hash then
		return nil, "hash mismatch"
	end

	return data
end

return CacheModel
