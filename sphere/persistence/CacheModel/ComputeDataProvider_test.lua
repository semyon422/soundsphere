local ComputeDataProvider = require("sphere.persistence.CacheModel.ComputeDataProvider")
local ChartfilesRepo = require("sphere.persistence.CacheModel.ChartfilesRepo")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local LocationsRepo = require("sphere.persistence.CacheModel.LocationsRepo")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")
local md5 = require("md5")

local test = {}

local function setup_db()
	local gdb = GameDatabase()
	gdb:load(":memory:")
	return gdb
end

function test.getChartData(t)
	local gdb = setup_db()
	local chartfilesRepo = ChartfilesRepo(gdb.models)
	local chartsRepo = ChartsRepo(gdb.models)
	local locationsRepo = LocationsRepo(gdb.models)

	local content = "content"
	local valid_hash = md5.sumhexa(content)
	
	local loc = locationsRepo:insertLocation({
		path = "charts", name = "game", is_relative = true, is_internal = true
	})
	
	local set = chartfilesRepo:insertChartfileSet({
		name = "set", dir = "dir", modified_at = 0, is_file = false, location_id = loc.id
	})
	
	chartfilesRepo:insertChartfile({
		name = "chart.sph", hash = valid_hash, set_id = set.id, path = "dir/set/chart.sph", modified_at = 0
	})
	
	local locationManager = {
		getPrefix = function(_, l) return l.path end
	}

	local fs = {
		read = function(_, path)
			if path == "charts/dir/set/chart.sph" then return content end
		end
	}
	
	local cdp = ComputeDataProvider(chartfilesRepo, chartsRepo, locationsRepo, locationManager, fs)
	
	local data, err = cdp:getChartData(valid_hash)
	t:assert(data, err)
	t:eq(data.name, "chart.sph")
	t:eq(data.data, content)

	gdb:unload()
end

return test
