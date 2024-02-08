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
	self.fileCacheGenerator = FileCacheGenerator(self.chartRepo, self.noteChartFinder)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartRepo, DifficultyModel)

	local function after(i, n, chartfile, noteCharts)
		print(chartfile.path)

		if noteCharts then
			for j, noteChart in ipairs(noteCharts) do
				self.chartdiffGenerator:create(noteChart, chartfile.hash, j)
			end
		end

		self.noteChartSetCount = 0
		self.noteChartCount = i
		self.cachePercent = (i - 1) / n * 100
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
	self.noteChartSetCount = 0
	self.noteChartCount = 0
	self.cachePercent = 0
	self.state = 0
end

function CacheManager:checkProgress()
	local thread = require("thread")
	thread:update()

	local cache = thread.shared.cache
	cache.noteChartSetCount = self.noteChartSetCount
	cache.noteChartCount = self.noteChartCount
	cache.cachePercent = self.cachePercent
	cache.state = self.state

	if cache.stop then
		cache.stop = false
		self.needStop = true
	end
end

---@param path string
---@param location_id number
---@param location_prefix string?
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
	self.chartmetaGenerator:generate(false, path, location_id, location_prefix)
	self:commit()

	self.state = 3
	self:checkProgress()
end

return CacheManager
