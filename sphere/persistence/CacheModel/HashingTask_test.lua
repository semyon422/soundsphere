local HashingTask = require("sphere.persistence.CacheModel.HashingTask")
local table_util = require("table_util")

local test = {}

function test.processChartfile(t)
	local actions = {}
	
	local fs = {
		read = function(_, path)
			table.insert(actions, {"read", path})
			return "content"
		end
	}
	
	local chartmetaGenerator = {
		generate = function(_, chartfile, content, not_reuse)
			table.insert(actions, {"generate", chartfile, content, not_reuse})
			return "cached", {{chart = {layers = {main = {toAbsolute = function() end}}}, chartmeta = {}}}
		end
	}
	
	local chartdiffGenerator = {
		create = function(_, chart, hash, index)
			table.insert(actions, {"create_diff", hash, index})
			return {id = 1}
		end
	}
	
	local task = HashingTask(fs, chartmetaGenerator, chartdiffGenerator)
	
	local chartfile = {path = "path/to/chart", hash = "hash"}
	local ok, err = task:processChartfile(chartfile, "prefix")
	
	t:assert(ok, err)
	t:eq(#actions, 3)
	t:tdeq(actions[1], {"read", "prefix/path/to/chart"})
	t:tdeq(actions[2], {"generate", chartfile, "content", false})
	t:tdeq(actions[3], {"create_diff", "hash", 1})
end

function test.read_error(t)
	local fs = {
		read = function()
			return nil, "error"
		end
	}
	local task = HashingTask(fs, {}, {})
	local ok, err = task:processChartfile({path = "path"}, "prefix")
	t:eq(ok, nil)
	t:assert(err:find("read error"))
end

return test
