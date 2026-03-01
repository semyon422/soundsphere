local thread = require("thread")
local class = require("class")
local pprint = require("pprint")
local ThreadRemote = require("threadremote.ThreadRemote")
local LoveFilesystem = require("fs.LoveFilesystem")
local ChartviewsRepo = require("rizu.library.repos.ChartviewsRepo")
local LocationsRepo = require("rizu.library.repos.LocationsRepo")
local Database = require("rizu.library.Database")
local Status = require("rizu.library.Status")
local ChartdiffGenerator = require("rizu.library.generators.ChartdiffGenerator")
local Locations = require("rizu.library.Locations")
local ChartfilesRepo = require("rizu.library.repos.ChartfilesRepo")
local ComputeDataProvider = require("rizu.library.ComputeDataProvider")

local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

---@class sphere.Location
---@field id integer
---@field path string
---@field name string
---@field is_relative boolean
---@field is_internal boolean

---@class sphere.IChartviewIds
---@field chartfile_id integer
---@field chartfile_set_id integer
---@field chartmeta_id integer
---@field chartdiff_id integer
---@field chartplay_id integer
---@field lamp boolean

---@class sphere.Chartview: sphere.IChartviewIds
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
---@field msd_diff? number
---@field accuracy? number
---@field miss_count? integer
---@field difftable_chartmetas? table[]

---@class sphere.RichChartview: sphere.Chartview
---@field location_prefix string
---@field location_dir string
---@field location_path string
---@field real_dir string
---@field real_path string

---@class rizu.library.Library
---@operator call: rizu.library.Library
local Library = class()

---@param difficultyModel sphere.DifficultyModel
function Library:new(difficultyModel)
	self.tasks = {}
	self.errors = {}
	self.shared = {
		state = 0,
		chartfiles_count = 0,
		chartfiles_current = 0,
		stop = false,
	}

	local migrations = {}
	setmetatable(migrations, {__index = function(_, k)
		local data = love.filesystem.read(("rizu/library/sql/migrate%s.sql"):format(k))
		return data
	end})

	self.database = Database(migrations)

	self.chartsRepo = ChartsRepo(self.database.models)
	self.difftablesRepo = DifftablesRepo(self.database.models)

	self.chartviewsRepo = ChartviewsRepo(self.database.models)
	self.locationsRepo = LocationsRepo(self.database.models)
	self.chartfilesRepo = ChartfilesRepo(self.database.models)
	self.status = Status(self.chartfilesRepo, self.chartsRepo)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartsRepo, difficultyModel)
	self.locations = Locations(
		self.locationsRepo,
		self.chartfilesRepo,
		LoveFilesystem(),
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)

	self.computeDataProvider = ComputeDataProvider(
		self.chartfilesRepo,
		self.chartsRepo,
		self.locationsRepo,
		self.locations,
		LoveFilesystem()
	)

	self.remote_handler = {
		updateProgress = function(state, count, current, errors)
			self.shared.state = state
			self.shared.chartfiles_count = count
			self.shared.chartfiles_current = current
			if errors then
				for _, err in ipairs(errors) do
					print("Library Error: " .. tostring(err))
					table.insert(self.errors, err)
				end
			end
		end
	}
end

function Library:load()
	self.database:load()
	self.status:update()

	self.locations:load()

	local tr = ThreadRemote(math.random(1000000), self.remote_handler)
	self.tr = tr
	self.worker = tr:start(function(remote)
		require("preload")
		local Worker = require("rizu.library.Worker")
		local worker = Worker()
		worker.remote = remote
		worker:init()
		return worker
	end)
end

function Library:unload()
	if self.tr then
		self.worker:unload()
		self.tr:stop()
	end
	self.database:unload()
end

Library.unload = thread.coro(Library.unload)

---@param path string
---@param location_id number
function Library:startUpdate(path, location_id)
	table.insert(self.tasks, {
		type = "update_cache",
		path = path,
		location_id = location_id,
	})
end

function Library:computeChartdiffs()
	table.insert(self.tasks, {
		type = "update_chartdiffs",
	})
end

---@param prefer_preview boolean
function Library:computeIncompleteChartdiffs(prefer_preview)
	table.insert(self.tasks, {
		type = "update_incomplete_chartdiffs",
		prefer_preview = prefer_preview,
	})
end

function Library:computeChartplays()
	table.insert(self.tasks, {
		type = "update_chartplays",
	})
end

---@param path string
---@param location_id number
function Library:startUpdateAsync(path, location_id)
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

function Library:stopTask()
	self.shared.stop = true
	if self.tr then
		self.worker:stopTask()
	end
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
	local task = table.remove(tasks, 1)
	while task do
		local callback = task.callback
		task.callback = nil

		self.database:unload()

		if task.type == "update_cache" then
			self.worker:computeCacheLocation(task.path, task.location_id)
		elseif task.type == "update_chartdiffs" then
			self.worker:computeChartdiffs()
		elseif task.type == "update_incomplete_chartdiffs" then
			self.worker:computeIncompleteChartdiffs(task.prefer_preview)
		elseif task.type == "update_chartplays" then
			self.worker:computeChartplays()
		end

		self.database:load()

		-- Also update library status after processing
		self.status:update()

		if callback then
			callback()
		end

		task = table.remove(tasks, 1)
	end

	self.isProcessing = false
end

Library.process = thread.coro(Library.process)

return Library
