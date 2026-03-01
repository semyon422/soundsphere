local Processor = require("rizu.library.Processor")
local Database = require("rizu.library.Database")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

function test.computeCacheLocation_sph(t)
	local fs = FakeFilesystem()
	fs.mount = function() return true end
	fs.unmount = function() return true end
	
	-- Create a fake location and a minimal SPH chart
	fs:createDirectory("/userdata/charts/test_pack")
	
	-- Minimal SPH needs 2 lines in # notes for tempo calculation
	local sph_content = [[
# metadata
input 4key
# notes
1000 =0
1000 =1
]]
	fs:write("/userdata/charts/test_pack/chart.sph", sph_content)
	
	local db = Database()
	db:load(":memory:")
	
	local processor = Processor(db, fs, "/fake/root")
	
	-- Make sure we don't depend on actual threads for the test
	require("thread").shared = require("thread").shared or {}
	require("thread").shared.cache = {}
	
	-- Use location 1 which is created by Locations:load() internally
	processor.locations:load()
	local loc = processor.locationsRepo:selectLocationById(1)
	t:assert(loc, "Default location should be created")
	
	-- Test computing the cache
	processor:computeCacheLocation(nil, 1)
	
	local count = processor.chartfilesRepo:countChartfiles()
	t:eq(count, 1, "Should have cached 1 chartfile")
	
	local chartfile = processor.chartfilesRepo:selectChartfile(1, "chart.sph")
	t:assert(chartfile, "chart.sph should be in the repository")
	t:assert(chartfile.hash, "chart.sph should be hashed")
	
	local chartmetas = processor.chartsRepo:countChartmetas()
	t:eq(chartmetas, 1, "Should have 1 chartmeta")
	
	local chartdiffs = processor.chartsRepo:countChartdiffs()
	t:eq(chartdiffs, 1, "Should have 1 chartdiff")
	
	db:unload()
end

return test
