local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local ChartdiffsRepo = require("sphere.persistence.CacheModel.ChartdiffsRepo")
local ChartmetasRepo = require("sphere.persistence.CacheModel.ChartmetasRepo")
local ChartFactory = require("notechart.ChartFactory")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ModifierModel = require("sphere.models.ModifierModel")
local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local ChartplaysRepo = require("sphere.persistence.CacheModel.ChartplaysRepo")
local ComputeDataProvider = require("sphere.persistence.CacheModel.ComputeDataProvider")
local ChartplayComputer = require("sea.chart.ChartplayComputer")
local ReplayCoder = require("sea.replays.ReplayCoder")
local ReplayConverter = require("sea.replays.ReplayConverter")
local ChartDecoder = require("sph.ChartDecoder")
local SphPreview = require("sph.SphPreview")
local Sph = require("sph.Sph")
local class = require("class")
local valid = require("valid")
local path_util = require("path_util")

---@class sphere.CacheManager
---@operator call: sphere.CacheManager
local CacheManager = class()

---@param gdb sphere.GameDatabase
function CacheManager:new(gdb)
	self.state = 0

	self.difficultyModel = DifficultyModel()

	self.gdb = gdb
	self.locationsRepo = LocationsRepo(gdb)
	self.chartplaysRepo = ChartplaysRepo(gdb)
	self.chartfilesRepo = ChartfilesRepo(gdb)
	self.chartdiffsRepo = ChartdiffsRepo(gdb, self.difficultyModel.registry.fields)
	self.chartmetasRepo = ChartmetasRepo(gdb)
	self.chartplayComputer = ChartplayComputer()

	self.noteChartFinder = NoteChartFinder(love.filesystem)

	local function handle_file_cache(chartfile)
		self.chartfiles_count = self.chartfiles_count + 1
		if self.chartfiles_count % 100 == 0 then
			self:checkProgress()
		end
	end
	self.fileCacheGenerator = FileCacheGenerator(self.chartfilesRepo, self.noteChartFinder, handle_file_cache)
	self.chartdiffGenerator = ChartdiffGenerator(self.chartdiffsRepo, self.difficultyModel)
	self.chartmetaGenerator = ChartmetaGenerator(self.chartmetasRepo, self.chartfilesRepo, ChartFactory)

	self.locationManager = LocationManager(
		self.locationsRepo,
		self.chartfilesRepo,
		nil,
		love.filesystem.getWorkingDirectory(),
		"mounted_charts"
	)

	self.computeDataProvider = ComputeDataProvider(
		self.chartfilesRepo,
		self.chartplaysRepo,
		self.locationsRepo,
		self.locationManager
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

---@param chartfile table
---@param location_prefix string
function CacheManager:processChartfile(chartfile, location_prefix)
	print(chartfile.path)

	local full_path = path_util.join(location_prefix, chartfile.path)
	local content = assert(love.filesystem.read(full_path))

	local ok, chart_chartmetas = self.chartmetaGenerator:generate(chartfile, content, false)

	if not ok then
		return
	end

	if not chart_chartmetas then
		return
	end
	---@cast chart_chartmetas -string

	for j, t in ipairs(chart_chartmetas) do
		local ok, err = xpcall(t.chart.layers.main.toAbsolute, debug.traceback, t.chart.layers.main)
		if not ok then
			print("toAbsolute", err)
			goto continue
		end
		local ok, err = self.chartdiffGenerator:create(t.chart, chartfile.hash, j)
		if not ok then
			print(err)
		end
		::continue::
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
	print("fileCacheGenerator.lookup", path, location_id, location_prefix)
	self.fileCacheGenerator:lookup(path, location_id, location_prefix)
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
	local content = assert(love.filesystem.read(full_path))

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
	local chartmetasRepo = self.chartmetasRepo
	local chartplaysRepo = self.chartplaysRepo

	local scores = chartplaysRepo:getChartplaysWithMissingChartdiffs()
	local chartmetas = chartmetasRepo:getChartmetasWithMissingChartdiffs()

	self.state = 2
	self.chartfiles_count = #chartmetas + #scores
	self.chartfiles_current = 0
	self:checkProgress()

	print("computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		local charts, err = self:getChartsByHash(chartmeta.hash)
		if not charts then
			print(err)
		else
			local chart = charts[chartmeta.index]

			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				local chartdiff = self.chartdiffGenerator:compute(chart, 1)
				chartdiff.hash = chartmeta.hash
				chartdiff.index = chartmeta.index
				self.chartdiffsRepo:createUpdateChartdiff(chartdiff)
			else
				print("toAbsolute", err)
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
		local charts, err = self:getChartsByHash(score.hash)
		if not charts then
			print(err)
		else
			local chart = charts[score.index]
			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				ModifierModel:apply(score.modifiers, chart)

				local chartdiff = self.chartdiffGenerator:compute(chart, score.rate)
				chartdiff.modifiers = score.modifiers
				chartdiff.hash = score.hash
				chartdiff.index = score.index

				self.chartdiffsRepo:createUpdateChartdiff(chartdiff)
			else
				print("toAbsolute", err)
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

---@param prefer_preview boolean
function CacheManager:computeIncompleteChartdiffs(prefer_preview)
	local chartdiffsRepo = self.chartdiffsRepo

	local chartdiffs = chartdiffsRepo:getIncompleteChartdiffs()
	print(#chartdiffs)

	self.state = 2
	self.chartfiles_count = #chartdiffs
	self.chartfiles_current = 0

	print("computing incomplete chartdiffs")
	for i, chartdiff in ipairs(chartdiffs) do
		---@type ncdk2.Chart
		local chart

		local chartfile = self.chartfilesRepo:selectChartfileByHash(chartdiff.hash)
		print(chartfile and chartfile.path)

		local preview = chartdiff.notes_preview
		if preview and prefer_preview then
			local lines = SphPreview:decodeLines(preview)

			local sph = Sph()
			sph.metadata.input = assert(chartdiff.inputmode)
			sph.sphLines:decode(lines)

			local decoder = ChartDecoder()
			chart = decoder:decodeSph(sph)
		else
			local charts, err = self:getChartsByHash(chartdiff.hash)
			if not charts then
				print(err)
			else
				chart = charts[chartdiff.index]
				local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
				if not ok then
					chart = nil
					print("toAbsolute", err)
				else
					ModifierModel:apply(chartdiff.modifiers, chart)
				end
			end
		end

		if chart then
			self.difficultyModel:compute(chartdiff, chart, chartdiff.rate)
			chartdiffsRepo:updateChartdiff(chartdiff)
		end

		self.chartfiles_current = i

		self:checkProgress()
		if self.needStop then
			break
		end
	end

	self.state = 0
	self:checkProgress()
end

---@param chartplay sea.Chartplay
function CacheManager:computeChartplay(chartplay)
	local chartplaysRepo = self.chartplaysRepo
	local chartplayComputer = self.chartplayComputer
	local computeDataProvider = self.computeDataProvider

	local chartfile_data, err = computeDataProvider:getChartData(chartplay.hash)
	if not chartfile_data then
		return nil, "get chart data: " .. err
	end

	local replay_data, err = computeDataProvider:getReplayData(chartplay.replay_hash)
	if not replay_data then
		return nil, "get replay data: " .. err
	end

	local replay, err = ReplayCoder.decode(replay_data)
	if not replay then
		return nil, "can't decode replay: " .. err
	end

	replay = ReplayConverter:convert(replay)

	local ok, err = valid.format(replay:validate())
	if not ok then
		-- print(require("stbl").encode(replay.modifiers))
		return nil, "validate replay: " .. err
	end

	local ret, err = chartplayComputer:compute(
		chartfile_data.name,
		chartfile_data.data,
		chartplay.index,
		replay
	)
	if not ret then
		print(err)
		return
	end

	print(require("stbl").encode(ret.chartplay_computed))

	return true
end

function CacheManager:computeChartplays()
	local chartplaysRepo = self.chartplaysRepo

	local chartplays = chartplaysRepo:getChartplaysNullComputeState()
	print(#chartplays)

	self.chartfiles_count = #chartplays
	self.chartfiles_current = 0

	self.state = 1
	self:checkProgress()

	for i, chartplay in ipairs(chartplays) do
		local ok, err = self:computeChartplay(chartplay)
		if not ok then
			print(chartplay.replay_hash .. ": " .. err)
		end

		self.chartfiles_current = i

		self:checkProgress()
		if self.needStop then
			break
		end
	end

	self.state = 0
	self:checkProgress()
end

return CacheManager
