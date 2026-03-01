local Locations = require("rizu.library.Locations")
local LocationsRepo = require("rizu.library.repos.LocationsRepo")
local ChartfilesRepo = require("rizu.library.repos.ChartfilesRepo")
local Database = require("rizu.library.Database")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

local function setup_db()
	local db = Database()
	db:load(":memory:")
	return db
end

function test.mounting(t)
	local db = setup_db()
	local locationsRepo = LocationsRepo(db.models)
	local chartfilesRepo = ChartfilesRepo(db.models)
	
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
	
	local lm = Locations(locationsRepo, chartfilesRepo, fs, "/game", "prefix")
	
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
	
	db:unload()
end

return test
