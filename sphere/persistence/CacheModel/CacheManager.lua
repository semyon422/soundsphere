local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local NoteChartFactory = require("notechart.NoteChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local class = require("class")

---@class sphere.CacheManager
---@operator call: sphere.CacheManager
local CacheManager = class()

function CacheManager:new(cdb)
	self.state = 0

	self.cdb = cdb
	self.chartRepo = ChartRepo(cdb)

	self.noteChartFinder = NoteChartFinder(love.filesystem)

	local function handle_file_cache(chartfile)
		self.chartfiles_count = self.chartfiles_count + 1
		if self.chartfiles_count % 100 == 0 then
			self:checkProgress()
		end
	end
	self.fileCacheGenerator = FileCacheGenerator(self.chartRepo, self.noteChartFinder, handle_file_cache)

	self.chartdiffGenerator = ChartdiffGenerator(self.chartRepo, DifficultyModel)

	local function after(i, n, chartfile, noteCharts)
		print(chartfile.path)

		if noteCharts then
			for j, noteChart in ipairs(noteCharts) do
				self.chartdiffGenerator:create(noteChart, chartfile.hash, j)
			end
		end

		self.chartfiles_count = n
		self.chartfiles_current = i
		self:checkProgress()

		if self.needStop then
			return true
		end
		if i % 100 == 0 then
			self:commit()
			self:begin()
		end
	end

	local function error_handler(chartfile, err)
		print(chartfile.id)
		print(chartfile.path)
		print(err)
	end

	self.chartmetaGenerator = ChartmetaGenerator(
		self.chartRepo,
		NoteChartFactory,
		love.filesystem,
		after,
		error_handler
	)
end

function CacheManager:begin()
	self.cdb.orm:begin()
end

function CacheManager:commit()
	self.cdb.orm:commit()
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

	self:begin()
	self.chartmetaGenerator:generate(path, location_id, location_prefix, false)
	self:commit()

	self.state = 0
	self:checkProgress()
end

return CacheManager
