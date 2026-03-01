local ComputeDataProvider = require("sphere.persistence.CacheModel.ComputeDataProvider")
local md5 = require("md5")

local test = {}

function test.getChartData(t)
	local content = "content"
	local valid_hash = md5.sumhexa(content)
	
	local chartfilesRepo = {
		selectChartfileByHash = function(_, hash)
			if hash == valid_hash then
				return {set_id = 1, name = "chart.sph"}
			end
		end,
		selectChartfileSetById = function(_, id)
			if id == 1 then
				return {location_id = 1, dir = "dir", name = "set"}
			end
		end
	}
	
	local locationsRepo = {
		selectLocationById = function(_, id)
			if id == 1 then
				return {id = 1, is_relative = true, path = "charts"}
			end
		end
	}
	
	local locationManager = {
		getPrefix = function(_, loc)
			return loc.path
		end
	}

	local fs = {
		read = function(_, path)
			if path == "charts/dir/set/chart.sph" then
				return content
			end
		end
	}
	
	local cdp = ComputeDataProvider(chartfilesRepo, {}, locationsRepo, locationManager, fs)
	
	local data, err = cdp:getChartData(valid_hash)
	t:assert(data, err)
	t:eq(data.name, "chart.sph")
	t:eq(data.data, content)
end

return test
