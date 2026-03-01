local path_util = require("path_util")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

local function setup_db()
	local gdb = GameDatabase()
	gdb:load(":memory:")
	gdb:applyViews()
	return gdb
end

function test.rel_root(t)
	local gdb = setup_db()
	local chartRepo = ChartfilesRepo(gdb.models)
	local locationsRepo = LocationsRepo(gdb.models)
	locationsRepo:insertLocation({id = 1, path = "prefix", name = "test", is_relative = false, is_internal = false})

	local fs = FakeFilesystem()
	fs:createDirectory("prefix/chartset")
	fs:write("prefix/chartset/chart1.osu", "content")
	fs:write("prefix/chartset/chart2.osu", "content")

	local ncf = NoteChartFinder(fs)
	local context = FakeTaskContext()
	local fcg = FileCacheGenerator(chartRepo, ncf, context)
	
	fcg:scan("chartset", 1, "prefix")

	local sets = chartRepo:selectChartfileSetsAtLocation(1)
	t:eq(#sets, 1)
	t:eq(sets[1].name, "chartset")

	local charts = chartRepo:selectUnhashedChartfiles(nil, 1, sets[1].id)
	t:eq(#charts, 2)
	
	gdb:unload()
end

function test.unrel_root(t)
	local gdb = setup_db()
	local chartRepo = ChartfilesRepo(gdb.models)
	local locationsRepo = LocationsRepo(gdb.models)
	locationsRepo:insertLocation({id = 1, path = "prefix", name = "test", is_relative = false, is_internal = false})

	local fs = FakeFilesystem()
	fs:createDirectory("prefix/charts")
	fs:write("prefix/charts/chart1.ojn", "content")
	fs:write("prefix/charts/chart2.ojn", "content")

	local ncf = NoteChartFinder(fs)
	local context = FakeTaskContext()
	local fcg = FileCacheGenerator(chartRepo, ncf, context)
	
	fcg:scan("charts", 1, "prefix")

	local sets = chartRepo:selectChartfileSetsAtLocation(1)
	t:eq(#sets, 2)
	t:eq(sets[1].name, "chart1.ojn")
	t:eq(sets[2].name, "chart2.ojn")

	gdb:unload()
end

function test.complex(t)
	local gdb = setup_db()
	local chartRepo = ChartfilesRepo(gdb.models)
	local locationsRepo = LocationsRepo(gdb.models)
	locationsRepo:insertLocation({id = 1, path = "prefix", name = "test", is_relative = false, is_internal = false})

	local fs = FakeFilesystem()
	-- Directory root/osucharts/chartset1 -> 2 osu files
	fs:createDirectory("prefix/root/osucharts/chartset1")
	fs:write("prefix/root/osucharts/chartset1/a.osu", "content")
	fs:write("prefix/root/osucharts/chartset1/b.osu", "content")
	
	-- Directory root/osucharts/chartset2 -> 2 osu files
	fs:createDirectory("prefix/root/osucharts/chartset2")
	fs:write("prefix/root/osucharts/chartset2/a.osu", "content")
	fs:write("prefix/root/osucharts/chartset2/b.osu", "content")
	
	-- Directory root/jamcharts -> 2 ojn files
	fs:createDirectory("prefix/root/jamcharts")
	fs:write("prefix/root/jamcharts/a.ojn", "content")
	fs:write("prefix/root/jamcharts/b.ojn", "content")

	local ncf = NoteChartFinder(fs)
	local context = FakeTaskContext()
	local fcg = FileCacheGenerator(chartRepo, ncf, context)

	fcg:scan("root", 1, "prefix")

	-- Expecting 4 chartfile sets:
	-- 1. root/osucharts/chartset1
	-- 2. root/osucharts/chartset2
	-- 3. a.ojn (in root/jamcharts)
	-- 4. b.ojn (in root/jamcharts)
	t:eq(chartRepo:countChartfileSets({location_id = 1}), 4)
	-- Total 6 chartfiles (2 + 2 + 1 + 1)
	t:eq(chartRepo:countChartfiles({location_id = 1}), 6)

	gdb:unload()
end

return test
