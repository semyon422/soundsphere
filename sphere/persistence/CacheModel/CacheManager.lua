local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local ChartFactory = require("notechart.ChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local ComputeDataProvider = require("sphere.persistence.CacheModel.ComputeDataProvider")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local ChartsComputer = require("sea.compute.ChartsComputer")
local HashingTask = require("sphere.persistence.CacheModel.HashingTask")
local DifficultyTask = require("sphere.persistence.CacheModel.DifficultyTask")
local ScoreTask = require("sphere.persistence.CacheModel.ScoreTask")
local class = require("class")
local path_util = require("path_util")

local LoveFilesystem = require("fs.LoveFilesystem")

---@class sphere.CacheManager
---@operator call: sphere.CacheManager
local CacheManager = class()

---@param gdb sphere.GameDatabase
---@param fs fs.IFilesystem
---@param workingDirectory string
function CacheManager:new(gdb, fs, workingDirectory)
	self.state = 0
	self.fs = fs

	self.difficultyModel = DifficultyModel()

	self.gdb = gdb

	self.chartsRepo = ChartsRepo(gdb.models, self.difficultyModel.registry.fields)

	self.locationsRepo = LocationsRepo(gdb)
	self.chartfilesRepo = ChartfilesRepo(gdb)

	self.noteChartFinder = NoteChartFinder(self.fs)

	local function handle_file_cache(chartfile)
		self.chartfiles_count = self.chartfiles_count + 1
		if self.chartfiles_count % 100 == 0 then
			self:checkProgress()
		end
	end
	self.fileCacheGenerator = FileCacheGenerator(self.chartfilesRepo, self.noteChartFinder, handle_file_cache)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartsRepo, self.difficultyModel)
	self.chartmetaGenerator = ChartmetaGenerator(self.chartsRepo, self.chartfilesRepo, ChartFactory)
	self.hashingTask = HashingTask(self.fs, self.chartmetaGenerator, self.chartdiffGenerator)
	self.difficultyTask = DifficultyTask(self.difficultyModel, self.chartsRepo, self)

	self.locationManager = LocationManager(
		self.locationsRepo,
		self.chartfilesRepo,
		self.fs,
		workingDirectory,
		"mounted_charts"
	)

	self.computeDataProvider = ComputeDataProvider(
		self.chartfilesRepo,
		self.chartsRepo,
		self.locationsRepo,
		self.locationManager
	)
	self.computeDataLoader = ComputeDataLoader(self.computeDataProvider)

	self.chartsComputer = ChartsComputer(self.computeDataLoader, self.chartsRepo)
	self.scoreTask = ScoreTask(self.chartsRepo, self.chartsComputer, self)
end

function CacheManager:begin()
	self.gdb.orm:begin()
end

function CacheManager:commit()
	self.gdb.orm:commit()
end

----------------------------------------------------------------

function CacheManager:resetProgress()
	self.chartfiles_count = 0
	self.chartfiles_current = 0
	self.state = 0
end

function CacheManager:checkProgress()
	local thread = require("thread")
	thread:update()

	local cache = thread.shared.cache
	if cache then
		cache.chartfiles_count = self.chartfiles_count
		cache.chartfiles_current = self.chartfiles_current
		cache.state = self.state

		if cache.stop then
			cache.stop = false
			self.needStop = true
		end
	end
end

---@param path string?
---@param location_id number
function CacheManager:computeCacheLocation(path, location_id)
	print("start caching", path, location_id)

	local location = self.locationsRepo:selectLocationById(location_id)
	local location_prefix = self.locationManager:getPrefix(location)

	self:resetProgress()

	self.state = 1
	self:checkProgress()

	self:begin()
	print("fileCacheGenerator.scan", path, location_id, location_prefix)
	self.fileCacheGenerator:scan(path, location_id, location_prefix)
	self:commit()

	self.state = 2
	self:checkProgress()

	local chartfile_set, set_id, unhashed_path
	local dir, name = NoteChartFinder.get_dir_name(path)
	if name then
		chartfile_set = self.chartfilesRepo:selectChartfileSet(dir, name, location_id)
	end
	if chartfile_set then
		set_id = chartfile_set.id
		print("chartfile_set.id = " .. set_id)
	else
		unhashed_path = path
	end

	print("chartfilesRepo.selectUnhashedChartfiles", unhashed_path, location_id, set_id)
	local chartfiles = self.chartfilesRepo:selectUnhashedChartfiles(unhashed_path, location_id, set_id)
	self.chartfiles_count = #chartfiles

	self:begin()
	for i, chartfile in ipairs(chartfiles) do
		self.chartfiles_current = i

		self.hashingTask:processChartfile(chartfile, location_prefix)
		self:checkProgress()

		if self.needStop then
			break
		end
		if i % 100 == 0 then
			self:commit()
			self:begin()
		end
	end
	self:commit()

	self.state = 0
	self:checkProgress()
end

---@param hash string
---@return ncdk2.Chart[]?
---@return string?
function CacheManager:getChartsByHash(hash)
	local chartfile = self.chartfilesRepo:selectChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found for " .. hash
	end

	local location = self.locationsRepo:selectLocationById(chartfile.location_id)
	local prefix = self.locationManager:getPrefix(location)

	local full_path = path_util.join(prefix, chartfile.path)
	local content = assert(self.fs:read(full_path))

	local chart_chartmetas, err = ChartFactory:getCharts(chartfile.name, content)
	if not chart_chartmetas then
		return nil, err
	end

	---@type ncdk2.Chart[]
	local charts = {}
	for i, t in ipairs(chart_chartmetas) do
		charts[i] = t.chart
	end

	return charts
end

function CacheManager:computeChartdiffs()
	self.difficultyTask:computeMissing()
end

---@param prefer_preview boolean
function CacheManager:computeIncompleteChartdiffs(prefer_preview)
	self.difficultyTask:computeIncomplete(prefer_preview)
end

function CacheManager:computeChartplays()
	self.scoreTask:computeAll()
end

return CacheManager
