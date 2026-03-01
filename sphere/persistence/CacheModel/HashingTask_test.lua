local HashingTask = require("sphere.persistence.CacheModel.HashingTask")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")
local ChartdiffGenerator = require("sphere.persistence.CacheModel.ChartdiffGenerator")
local DifficultyModel = require("sphere.models.DifficultyModel")
local FakeFilesystem = require("fs.FakeFilesystem")
local digest = require("digest")

local test = {}

local function setup_db()
	local gdb = GameDatabase()
	gdb:load(":memory:")
	gdb:applyViews()
	return gdb
end

function test.processChartfile(t)
	local gdb = setup_db()
	local chartfilesRepo = ChartfilesRepo(gdb.models)
	local chartsRepo = ChartsRepo(gdb.models)
	local locationsRepo = LocationsRepo(gdb.models)
	
	locationsRepo:insertLocation({id = 1, path = "prefix", name = "test", is_relative = false, is_internal = false})

	local set = chartfilesRepo:insertChartfileSet({
		name = "set", modified_at = 0, is_file = false, location_id = 1
	})
	local chartfile = chartfilesRepo:insertChartfile({
		name = "chart.sph", modified_at = 0, set_id = set.id, path = "set/chart.sph"
	})

	local fs = FakeFilesystem()
	local content = [[
# metadata
input 4key
# notes
1000 =0
1000 =1
]]
	fs:write("prefix/set/chart.sph", content)
	local expected_hash = digest.hash("md5", content, true)

	-- Setup real generators
	local ChartFactory = require("notechart.ChartFactory")
	local cmg = ChartmetaGenerator(chartsRepo, chartfilesRepo, ChartFactory)
	
	local difficultyModel = DifficultyModel()
	local cdg = ChartdiffGenerator(chartsRepo, difficultyModel)
	
	local context = FakeTaskContext()
	local task = HashingTask(fs, cmg, cdg, context)
	
	local ok, err = task:processChartfile(chartfile, "prefix")
	t:assert(ok, err)
	
	-- Verify results in DB
	local updated_cf = chartfilesRepo:selectChartfileById(chartfile.id)
	t:eq(updated_cf.hash, expected_hash)
	
	local meta = chartsRepo:getChartmetaByHashIndex(expected_hash, 1)
	t:assert(meta)
	t:eq(meta.inputmode, "4key")
	
	local diff = chartsRepo:selectDefaultChartdiff(expected_hash, 1)
	t:assert(diff)
	t:ne(diff.enps_diff, 0)

	gdb:unload()
end

function test.read_error(t)
	local fs = FakeFilesystem() -- Empty filesystem
	
	local context = FakeTaskContext()
	-- Generators don't matter for read error
	local task = HashingTask(fs, {}, {}, context)
	local ok, err = task:processChartfile({path = "non-existent"}, "prefix")
	
	t:ne(ok, true)
	t:assert(err:match("read error") and true)
	t:eq(#context.actions, 1)
	t:eq(context.actions[1][1], "addError")
end

return test
