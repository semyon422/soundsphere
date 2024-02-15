local LocationManager = require("sphere.persistence.CacheModel.LocationManager")
local table_util = require("table_util")

local test = {}

function test.all(t)
	local locations = {}

	local chartRepo = {}
	function chartRepo:selectLocations()
		return locations
	end
	function chartRepo:selectLocation(path)
		local i = table_util.indexof(locations, path, function(l) return l.path end)
		return locations[i]
	end
	function chartRepo:selectLocationById(id)
		local i = table_util.indexof(locations, id, function(l) return l.id end)
		return locations[i]
	end
	function chartRepo:insertLocation(location)
		table.insert(locations, location)
		location.id = #locations
		return location
	end

	local fs = {}
	function fs.mount() return true end

	local lm = LocationManager(chartRepo, fs, "/game", "prefix")

	lm:createLocation({path = "/dir"})
	lm:createLocation({path = "/game/dir"})
	lm:createLocation({path = "/game/dir"})

	t:eq(#locations, 2)

	local loc1 = chartRepo:selectLocationById(1)
	t:eq(loc1.is_relative, false)
	t:eq(loc1.path, "/dir")
	t:eq(lm:getPrefix(loc1), "prefix/1")

	local loc2 = chartRepo:selectLocationById(2)
	t:eq(loc2.is_relative, true)
	t:eq(loc2.path, "dir")
	t:eq(lm:getPrefix(loc2), "dir")
end

return test
