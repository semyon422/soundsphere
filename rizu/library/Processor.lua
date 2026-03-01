local LocationsRepo = require("rizu.library.repos.LocationsRepo")
local Finder = require("rizu.library.Finder")
local FileCacheGenerator = require("rizu.library.generators.FileCacheGenerator")
local ChartmetaGenerator = require("rizu.library.generators.ChartmetaGenerator")
local ChartdiffGenerator = require("rizu.library.generators.ChartdiffGenerator")
local ChartfilesRepo = require("rizu.library.repos.ChartfilesRepo")
local ChartFactory = require("notechart.ChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local Locations = require("rizu.library.Locations")
local ComputeDataProvider = require("rizu.library.ComputeDataProvider")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local ChartsComputer = require("sea.compute.ChartsComputer")
local HashingTask = require("rizu.library.tasks.HashingTask")
local DifficultyTask = require("rizu.library.tasks.DifficultyTask")
local ScoreTask = require("rizu.library.tasks.ScoreTask")
local TaskContext = require("rizu.library.tasks.TaskContext")
local class = require("class")
local path_util = require("path_util")

---@class rizu.library.Processor
---@operator call: rizu.library.Processor
local Processor = class()

---@param libraryDatabase rizu.library.Database
---@param fs fs.IFilesystem
---@param workingDirectory string
function Processor:new(libraryDatabase, fs, workingDirectory)
	self.state = 0
	self.fs = fs

	self.difficultyModel = DifficultyModel()

	self.database = libraryDatabase

	self.chartsRepo = ChartsRepo(self.database.models, self.difficultyModel.registry.fields)

	self.locationsRepo = LocationsRepo(self.database.models)
	self.chartfilesRepo = ChartfilesRepo(self.database.models)

	self.finder = Finder(self.fs)

	self.taskContext = TaskContext(self)

	self.fileCacheGenerator = FileCacheGenerator(self.chartfilesRepo, self.finder, self.taskContext)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartsRepo, self.difficultyModel)
	self.chartmetaGenerator = ChartmetaGenerator(self.chartsRepo, self.chartfilesRepo, ChartFactory)
	self.hashingTask = HashingTask(self.fs, self.chartmetaGenerator, self.chartdiffGenerator, self.taskContext)
	self.difficultyTask = DifficultyTask(self.difficultyModel, self.chartdiffGenerator, self.chartsRepo, self.taskContext)

	self.locations = Locations(
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
		self.locations,
		self.fs
	)
	self.computeDataLoader = ComputeDataLoader(self.computeDataProvider)

	self.chartsComputer = ChartsComputer(self.computeDataLoader, self.chartsRepo)
	self.scoreTask = ScoreTask(self.chartsRepo, self.chartsComputer, self.taskContext)
end

function Processor:begin()
	self.database.orm:begin()
end

function Processor:commit()
	self.database.orm:commit()
end

----------------------------------------------------------------

function Processor:resetProgress()
	self.chartfiles_count = 0
	self.chartfiles_current = 0
	self.state = 0
	self.errors = {}
end

function Processor:addError(err)
	table.insert(self.errors, tostring(err))
	self:checkProgress()
end

function Processor:checkProgress() end

---@param path string?
---@param location_id number
function Processor:computeCacheLocation(path, location_id)
	print("start caching", path, location_id)

	local location = self.locationsRepo:selectLocationById(location_id)
	local location_prefix = self.locations:getPrefix(location)

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
	local dir, name = Finder.get_dir_name(path)
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
function Processor:getChartsByHash(hash)
	local chartfile = self.chartfilesRepo:selectChartfileByHash(hash)
	if not chartfile then
		return nil, "chartfile not found for " .. hash
	end

	local location = self.locationsRepo:selectLocationById(chartfile.location_id)
	local prefix = self.locations:getPrefix(location)

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

function Processor:computeChartdiffs()
	self.difficultyTask:computeMissing()
end

---@param prefer_preview boolean
function Processor:computeIncompleteChartdiffs(prefer_preview)
	self.difficultyTask:computeIncomplete(prefer_preview)
end

function Processor:computeChartplays()
	self.scoreTask:computeAll()
end

return Processor
