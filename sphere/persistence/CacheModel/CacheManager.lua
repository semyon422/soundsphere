local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local ChartdiffsRepo = require("sphere.persistence.CacheModel.ChartdiffsRepo")
local ChartmetasRepo = require("sphere.persistence.CacheModel.ChartmetasRepo")
local NoteChartFactory = require("notechart.NoteChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ModifierModel = require("sphere.models.ModifierModel")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local ScoresRepo = require("sphere.persistence.CacheModel.ScoresRepo")
local class = require("class")
local path_util = require("path_util")

---@class sphere.CacheManager
---@operator call: sphere.CacheManager
local CacheManager = class()

---@param gdb sphere.GameDatabase
function CacheManager:new(gdb)
	self.state = 0

	self.gdb = gdb
	self.locationsRepo = LocationsRepo(gdb)
	self.scoresRepo = ScoresRepo(gdb)
	self.chartfilesRepo = ChartfilesRepo(gdb)
	self.chartdiffsRepo = ChartdiffsRepo(self.gdb)
	self.chartmetasRepo = ChartmetasRepo(self.gdb)

	self.noteChartFinder = NoteChartFinder(love.filesystem)

	local function handle_file_cache(chartfile)
		self.chartfiles_count = self.chartfiles_count + 1
		if self.chartfiles_count % 100 == 0 then
			self:checkProgress()
		end
	end
	self.fileCacheGenerator = FileCacheGenerator(self.chartfilesRepo, self.noteChartFinder, handle_file_cache)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartdiffsRepo, DifficultyModel)
	self.chartmetaGenerator = ChartmetaGenerator(self.chartmetasRepo, self.chartfilesRepo, NoteChartFactory)

	self.locationManager = LocationManager(
		self.locationsRepo,
		self.chartfilesRepo,
		nil,
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)
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
	cache.chartfiles_count = self.chartfiles_count
	cache.chartfiles_current = self.chartfiles_current
	cache.state = self.state

	if cache.stop then
		cache.stop = false
		self.needStop = true
	end
end

function CacheManager:processChartfile(chartfile, location_prefix)
	print(chartfile.path)

	local full_path = path_util.join(location_prefix, chartfile.path)
	local content = assert(love.filesystem.read(full_path))

	local ok, err = self.chartmetaGenerator:generate(chartfile, content, false)

	if not ok then
		print(chartfile.id)
		print(err)
		return
	end

	if not err then
		return
	end

	for j, noteChart in ipairs(err) do
		self.chartdiffGenerator:create(noteChart, chartfile.hash, j)
	end
end

---@param path string?
---@param location_id number
---@param location_prefix string
function CacheManager:generateCacheFull(path, location_id, location_prefix)
	self:resetProgress()

	self.state = 1
	self:checkProgress()

	self:begin()
	self.fileCacheGenerator:lookup(path, location_id, location_prefix)
	self:commit()

	self.state = 2
	self:checkProgress()

	local chartfile_set, set_id
	local dir, name = NoteChartFinder.get_dir_name(path)
	if name then
		chartfile_set = self.chartfilesRepo:selectChartfileSet(dir, name)
	end
	if chartfile_set then
		set_id = chartfile_set.id
		print("chartfile_set.id = " .. set_id)
	end

	local chartfiles = self.chartfilesRepo:selectUnhashedChartfiles(location_id, set_id)
	self.chartfiles_count = #chartfiles

	self:begin()
	for i, chartfile in ipairs(chartfiles) do
		self.chartfiles_current = i

		self:processChartfile(chartfile, location_prefix)
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

function CacheManager:computeChartdiffs()
	local chartmetasRepo = self.chartmetasRepo
	local scoresRepo = self.scoresRepo
	local chartfilesRepo = self.chartfilesRepo

	local scores = scoresRepo:getScoresWithMissingChartdiffs()
	local chartmetas = chartmetasRepo:getChartmetasWithMissingChartdiffs()

	self.state = 2
	self.chartfiles_count = #chartmetas + #scores
	self.chartfiles_current = 0
	self:checkProgress()

	print("computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		local chartfile = chartfilesRepo:selectChartfileByHash(chartmeta.hash)
		if chartfile then
			local location = self.locationsRepo:selectLocationById(chartfile.location_id)
			local prefix = self.locationManager:getPrefix(location)

			local full_path = path_util.join(prefix, chartfile.path)
			local content = assert(love.filesystem.read(full_path))

			local noteChart, err = NoteChartFactory:getNoteChart(chartfile.name, content, chartmeta.index)
			if not noteChart then
				return nil, err
			else
				local chartdiff = self.chartdiffGenerator:compute(noteChart)
				chartdiff.hash = chartmeta.hash
				chartdiff.index = chartmeta.index
				self.chartdiffGenerator:createUpdateChartdiff(chartdiff)
			end
		end
		self.chartfiles_current = self.chartfiles_current + 1
		self:checkProgress()
		if self.needStop then
			break
		end
	end

	print("computing modified chartdiffs")
	for i, score in ipairs(scores) do
		local chartfile = chartfilesRepo:selectChartfileByHash(score.hash)
		local chartmeta = chartmetasRepo:selectChartmeta(score.hash, score.index)
		if chartfile and chartmeta then
			local location = self.locationsRepo:selectLocationById(chartfile.location_id)
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
				chartdiff.is_exp_rate = score.is_exp_rate

				self.chartdiffGenerator:createUpdateChartdiff(chartdiff)
			end
		end
		self.chartfiles_current = self.chartfiles_current + 1
		self:checkProgress()
		if self.needStop then
			break
		end
	end

	self.state = 0
	self:checkProgress()
end

return CacheManager
