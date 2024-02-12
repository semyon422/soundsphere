local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local table_util = require("table_util")

local test = {}

function test.all(t)
	local locations = {}

	local chartRepo = {}
	function chartRepo:selectChartfileLocations()
		return locations
	end
	function chartRepo:selectChartfileLocation(path)
		local i = table_util.indexof(locations, path, function(l) return l.path end)
		return locations[i]
	end
	function chartRepo:selectChartfileLocationById(id)
		local i = table_util.indexof(locations, id, function(l) return l.id end)
		return locations[i]
	end
	function chartRepo:insertChartfileLocation(location)
		table.insert(locations, location)
		location.id = #locations
		return location
	end

	local fs = {}
	function fs.mount() return true end

	local lm = LocationManager(chartRepo, fs, "/game", "prefix")

	lm:createLocation("/dir")
	lm:createLocation("/game/dir")
	lm:createLocation("/game/dir")

	t:eq(#locations, 2)

	local loc1 = chartRepo:selectChartfileLocationById(1)
	t:eq(lm:getPrefix(loc1), "prefix/1")
	t:eq(lm:getMountPoint(loc1), "prefix/1")

	local loc2 = chartRepo:selectChartfileLocationById(2)
	t:eq(lm:getPrefix(loc2), "dir")
	t:eq(lm:getMountPoint(loc2), nil)
end

return test
