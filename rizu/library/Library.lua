local thread = require("thread")
local class = require("class")
local Observable = require("aqua.Observable")
local ThreadRemote = require("threadremote.ThreadRemote")
local LoveFilesystem = require("fs.LoveFilesystem")
local ChartviewsRepo = require("rizu.library.repos.ChartviewsRepo")
local LocationsRepo = require("rizu.library.repos.LocationsRepo")
local Database = require("rizu.library.Database")
local Status = require("rizu.library.Status")
local ChartdiffGenerator = require("rizu.library.generators.ChartdiffGenerator")
local Collections = require("rizu.library.Collections")
local Locations = require("rizu.library.Locations")
local ChartfilesRepo = require("rizu.library.repos.ChartfilesRepo")
local ComputeDataProvider = require("rizu.library.ComputeDataProvider")

local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

---@class rizu.library.LibraryTask
---@field f fun()
---@field co thread?

---@class rizu.Location
---@field id integer
---@field path string
---@field name string
---@field is_relative boolean
---@field is_internal boolean

---@class rizu.IChartviewBase
---@field chartfile_id integer
---@field chartfile_set_id integer
---@field chartmeta_id integer
---@field chartdiff_id integer
---@field chartplay_id integer
---@field lamp boolean?

-- TODO: better types for all chartviews in views.sql
---@class rizu.Chartview: rizu.IChartviewBase
---@field hash string
---@field index integer
---@field title string
---@field artist string
---@field creator string
---@field level number
---@field inputmode string
---@field format string
---@field audio_path string
---@field background_path string
---@field location_id integer
---@field set_name string
---@field set_dir string
---@field chartfile_name string
---@field difficulty number
---@field notes_count integer
---@field duration number
---@field msd_diff number?
---@field accuracy number?
---@field miss_count integer?
---@field difftable_chartmetas table[]?

-- TODO: check if some fields can be optional
---@class rizu.LocatedChartview: rizu.Chartview
---@field location_prefix string
---@field location_dir string
---@field location_path string
---@field real_dir string
---@field real_path string

---@class rizu.library.Library
---@operator call: rizu.library.Library
local Library = class()

---@param difficultyModel sphere.DifficultyModel
---@param fs fs.IFilesystem
---@param workingDirectory string
---@param getTime fun(): number
function Library:new(difficultyModel, fs, workingDirectory, getTime)
	self.fs = fs
	self.workingDirectory = workingDirectory

	---@type rizu.library.LibraryTask[]
	self.tasks = {}

	---@type string[]
	self.errors = {}

	self.getTime = getTime

	self.onStatusChanged = Observable()

	---@type rizu.library.TaskStatus
	self.status = {
		stage = "idle",
		current = 0,
		total = 0,
		errorCount = 0
	}
	self.stageStartTime = self.getTime()
	self.is_sync = false

	local migrations = {}
	setmetatable(migrations, {__index = function(_, k)
		local path = ("rizu/library/sql/migrate%s.sql"):format(k)
		if self.fs:getInfo(path) then
			return self.fs:read(path)
		end
	end})

	self.database = Database(fs, migrations)

	self.chartsRepo = ChartsRepo(self.database.models)
	self.difftablesRepo = DifftablesRepo(self.database.models)

	self.chartviewsRepo = ChartviewsRepo(self.database.models)
	self.locationsRepo = LocationsRepo(self.database.models)
	self.chartfilesRepo = ChartfilesRepo(self.database.models)
	self.statusUpdate = Status(self.chartfilesRepo, self.chartsRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartsRepo, difficultyModel)
	self.collections = Collections(self.chartfilesRepo, self.locationsRepo)
	self.locations = Locations(
		self.locationsRepo,
		self.chartfilesRepo,
		fs,
		workingDirectory,
		"mounted_charts"
	)

	self.computeDataProvider = ComputeDataProvider(
		self.chartfilesRepo,
		self.chartsRepo,
		self.locationsRepo,
		self.locations,
		fs
	)
end

---@param is_sync boolean
function Library:setSync(is_sync)
	self.is_sync = is_sync
end

---@param dbPath string?
function Library:load(dbPath)
	self.database:load(dbPath)
	self.statusUpdate:update()

	self.locations:load()

	if self.is_sync then
		self.worker = self:createAndLoadWorker(self.workingDirectory)
	else
		self.tr = ThreadRemote("rizu.library.Library", self)
		self.worker = self.tr:start(self.createAndLoadWorker, self.workingDirectory)
	end
end

---@param workingDirectory string
function Library:createAndLoadWorker(workingDirectory)
	require("preload")
	local Worker = require("rizu.library.Worker")
	local LoveFilesystem = require("fs.LoveFilesystem")
	local worker = Worker(self, LoveFilesystem(), workingDirectory)
	worker:load()
	return worker
end

function Library:unload()
	self.worker:unload()
	if self.tr then
		self.tr:stop()
	end
	self.database:unload()
end

Library.unload = thread.coro(Library.unload)

---@param status rizu.library.TaskStatus
---@param errors string[]
function Library:updateProgress(status, errors)
	local now = self.getTime()
	if self.status.stage ~= status.stage then
		self.stageStartTime = now
	end

	self.status = status

	local elapsed = self.stageStartTime and (now - self.stageStartTime) or 0
	if elapsed > 0.5 and status.current > 0 then
		status.itemsPerSecond = status.current / elapsed
		if status.total > status.current then
			status.eta = (status.total - status.current) / status.itemsPerSecond
		end
	end

	for _, err in ipairs(errors) do
		print("Library error: " .. tostring(err))
		table.insert(self.errors, err)
	end

	self.onStatusChanged:send(self.status)
end

---@param locations_in_collections boolean
---@return rizu.library.Collections.TreeNode
function Library:getCollectionTree(locations_in_collections)
	return self.collections:getTree(locations_in_collections)
end

---@param f fun(worker: rizu.library.Library)
---@param async boolean?
function Library:addTask(f, async)
	---@type rizu.library.LibraryTask
	local task = {f = f}
	table.insert(self.tasks, task)

	if async then
		task.co = coroutine.running()
		coroutine.yield()
	end
end

---@param path string?
---@param location_id number
function Library:computeLocation(path, location_id)
	self:addTask(function()
		self.worker:computeLocation(path, location_id)
	end)
end

---@param path string?
---@param location_id integer
function Library:computeLocationAsync(path, location_id)
	self:addTask(function()
		self.worker:computeLocation(path, location_id)
	end, true)
end

function Library:computeChartdiffs()
	self:addTask(function()
		self.worker:computeChartdiffs()
	end)
end

---@param prefer_preview boolean
function Library:computeIncompleteChartdiffs(prefer_preview)
	self:addTask(function()
		self.worker:computeIncompleteChartdiffs(prefer_preview)
	end)
end

function Library:computeChartplays()
	self:addTask(function()
		self.worker:computeChartplays()
	end)
end

function Library:stopTask()
	self.worker:stopTask()
end

Library.stopTask = thread.coro(Library.stopTask)

function Library:update()
	if self.tr then
		self.tr:update()
	end
	if not self.isProcessing and #self.tasks > 0 then
		self:process()
	end
end

function Library:process()
	if self.isProcessing then
		return
	end
	self.isProcessing = true

	local tasks = self.tasks
	---@type rizu.library.LibraryTask?
	local task = table.remove(tasks, 1)
	while task do
		local ok, err = xpcall(task.f, debug.traceback)
		if not ok then
			print("Library Task Error: " .. tostring(err))
			table.insert(self.errors, tostring(err))
		end

		self.statusUpdate:update()

		if task.co then
			coroutine.resume(task.co)
		end

		task = table.remove(tasks, 1)
	end

	self.isProcessing = false
end

Library.process = thread.coro(Library.process)

return Library
