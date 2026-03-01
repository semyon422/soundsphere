local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

local function setup_db()
	local gdb = GameDatabase()
	gdb:load(":memory:")
	return gdb
end

function test.mounting(t)
	local gdb = setup_db()
	local locationsRepo = LocationsRepo(gdb.models)
	local chartfilesRepo = ChartfilesRepo(gdb.models)
	
	local mounts = {}
	local fs = {
		mount = function(_, archive, mp)
			mounts[mp] = archive
			return true
		end,
		unmount = function(_, archive)
			for mp, arch in pairs(mounts) do
				if arch == archive then
					mounts[mp] = nil
					return true
				end
			end
			return false
		end,
	}
	
	local lm = LocationManager(locationsRepo, chartfilesRepo, fs, "/game", "prefix")
	
	-- Test default location creation
	lm:load()
	local locations = locationsRepo:selectLocations()
	t:eq(#locations, 1)
	t:eq(locations[1].path, "userdata/charts")
	t:eq(locations[1].is_relative, true)
	
	-- Test adding a new external location
	local loc2 = locationsRepo:insertLocation({
		path = "/ext/charts", 
		name = "ext", 
		is_relative = false, 
		is_internal = false
	})
	
	lm:selectLocations()
	lm:mountLocation(loc2)
	
	t:eq(mounts["prefix/" .. loc2.id], "/ext/charts")
	t:eq(lm:getPrefix(loc2), "prefix/" .. loc2.id)
	
	-- Test relative path conversion
	lm:selectLocation(loc2.id)
	lm:updateLocationPath("/game/my_charts")
	
	local updated_loc2 = locationsRepo:selectLocationById(loc2.id)
	t:eq(updated_loc2.path, "my_charts")
	t:eq(updated_loc2.is_relative, true)
	t:eq(lm:getPrefix(updated_loc2), "my_charts")
	
	gdb:unload()
end

return test
