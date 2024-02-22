local thread = require("thread")
local class = require("class")
local physfs = require("physfs")
local path_util = require("path_util")
local CacheDatabase = require("sphere.persistence.CacheModel.CacheDatabase")
local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local ChartsDatabase = require("sphere.persistence.CacheModel.ChartsDatabase")
local CacheStatus = require("sphere.persistence.CacheModel.CacheStatus")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local OldScoresMigrator = require("sphere.persistence.CacheModel.OldScoresMigrator")
local DifficultyModel = require("sphere.models.DifficultyModel")
local NoteChartFactory = require("notechart.NoteChartFactory")
local ModifierModel = require("sphere.models.ModifierModel")

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

	self.oldScoresMigrator = OldScoresMigrator(self.chartRepo)
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

function CacheModel:computeScoresWithMissingChartdiffs()
	local chartRepo = self.chartRepo
	local scores = chartRepo:getScoresWithMissingChartdiffs()

	for _, score in ipairs(scores) do
		local chartfile = chartRepo:selectChartfileByHash(score.hash)
		local chartmeta = chartRepo:selectChartmeta(score.hash, score.index)
		if chartfile and chartmeta then
			local location = self.chartRepo:selectLocationById(chartfile.location_id)
			local prefix = self.locationManager:getPrefix(location)

			local full_path = path_util.join(prefix, chartfile.path)
			local content = assert(love.filesystem.read(full_path))

			local noteChart, err = NoteChartFactory:getNoteChart(chartfile.name, content, score.index)
			if not noteChart then
				return nil, err
			else
				ModifierModel:apply(score.modifiers, noteChart)

				local chartdiff = self.chartdiffGenerator:compute(noteChart, score.rate)
				chartdiff.modifiers = score.modifiers
				chartdiff.hash = score.hash
				chartdiff.index = score.index

				self.chartdiffGenerator:fillMeta(chartdiff, chartmeta)

				self.chartdiffGenerator:createUpdateChartdiff(chartdiff)
			end
		end
	end
end

return CacheModel
