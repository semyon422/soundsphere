local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local FakeFilesystem = require("fs.FakeFilesystem")

local test = {}

function test.mounting(t)
	local locations = {}
	local chartRepo = {
		selectLocations = function() return locations end,
		selectLocation = function(_, path)
			for _, l in ipairs(locations) do if l.path == path then return l end end
		end,
		insertLocation = function(_, l)
			table.insert(locations, l)
			l.id = #locations
			return l
		end,
		selectLocationById = function(_, id) return locations[id] end,
		updateLocation = function(_, l)
			for i, loc in ipairs(locations) do
				if loc.id == l.id then locations[i] = l break end
			end
		end
	}
	
	local chartfilesRepo = {
		countChartfileSets = function() return 0 end,
		countChartfiles = function() return 0 end
	}
	
	local _fs = FakeFilesystem()
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
		getWorkingDirectory = function() return "/game" end
	}
	
	local lm = LocationManager(chartRepo, chartfilesRepo, fs, "/game", "prefix")
	
	-- Test default location creation
	lm:load()
	t:eq(#locations, 1)
	t:eq(locations[1].path, "userdata/charts")
	t:eq(locations[1].is_relative, true)
	
	-- Test adding a new external location
	local loc2 = {path = "/ext/charts", name = "ext", is_relative = false, is_internal = false}
	chartRepo:insertLocation(loc2)
	lm:selectLocations()
	lm:mountLocation(loc2)
	
	t:eq(mounts["prefix/2"], "/ext/charts")
	t:eq(lm:getPrefix(loc2), "prefix/2")
	
	-- Test relative path conversion
	lm:selectLocation(2)
	lm:updateLocationPath("/game/my_charts")
	t:eq(loc2.path, "my_charts")
	t:eq(loc2.is_relative, true)
	t:eq(lm:getPrefix(loc2), "my_charts")
end

return test
