local HashingTask = require("sphere.persistence.CacheModel.HashingTask")
local FakeTaskContext = require("sphere.persistence.CacheModel.FakeTaskContext")
local table_util = require("table_util")

local test = {}

function test.processChartfile(t)
	local fs = {
		read = function(_, path)
			return "content"
		end
	}
	
	local chartmetaGenerator = {
		generate = function(_, chartfile, content, not_reuse)
			return "cached", {{chart = {layers = {main = {toAbsolute = function() end}}}, chartmeta = {}}}
		end
	}
	
	local chartdiffGenerator = {
		create = function(_, chart, hash, index)
			return {id = 1}
		end
	}
	
	local context = FakeTaskContext()
	local task = HashingTask(fs, chartmetaGenerator, chartdiffGenerator, context)
	
	local chartfile = {path = "path/to/chart", hash = "hash"}
	local ok, err = task:processChartfile(chartfile, "prefix")
	
	t:assert(ok, err)
	t:tdeq(context.actions, {})
end

function test.read_error(t)
	local fs = {
		read = function()
			return nil, "error"
		end
	}
	local context = FakeTaskContext()
	local task = HashingTask(fs, {}, {}, context)
	local ok, err = task:processChartfile({path = "path"}, "prefix")
	t:eq(ok, nil)
	t:assert(err:find("read error"))
	t:eq(#context.actions, 1)
	t:eq(context.actions[1][1], "addError")
end

return test
