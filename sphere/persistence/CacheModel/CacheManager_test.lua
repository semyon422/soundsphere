local CacheManager = require("sphere.persistence.CacheModel.CacheManager")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
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
	
	local gdb = GameDatabase()
	gdb:load(":memory:")
	
	local manager = CacheManager(gdb, fs, "/fake/root")
	
	-- Make sure we don't depend on actual threads for the test
	require("thread").shared = require("thread").shared or {}
	require("thread").shared.cache = {}
	
	-- Use location 1 which is created by LocationManager:load() internally
	manager.locationManager:load()
	local loc = manager.locationsRepo:selectLocationById(1)
	t:assert(loc, "Default location should be created")
	
	-- Test computing the cache
	manager:computeCacheLocation(nil, 1)
	
	local count = manager.chartfilesRepo:countChartfiles()
	t:eq(count, 1, "Should have cached 1 chartfile")
	
	local chartfile = manager.chartfilesRepo:selectChartfile(1, "chart.sph")
	t:assert(chartfile, "chart.sph should be in the repository")
	t:assert(chartfile.hash, "chart.sph should be hashed")
	
	local chartmetas = manager.chartsRepo:countChartmetas()
	t:eq(chartmetas, 1, "Should have 1 chartmeta")
	
	local chartdiffs = manager.chartsRepo:countChartdiffs()
	t:eq(chartdiffs, 1, "Should have 1 chartdiff")
	
	gdb:unload()
end

return test
