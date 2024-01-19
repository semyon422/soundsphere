local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")

local test = {}

local function get_fake_chartRepo(actions)
	local chartRepo = {}

	local chartfiles, chartfile_sets = {}, {}

	function chartRepo:selectChartfileSet(path)
		table.insert(actions, {"ss", path})
		return chartfile_sets[path]
	end
	function chartRepo:insertChartfileSet(chartfile_set)
		table.insert(actions, {"is", chartfile_set})
		chartfile_sets[chartfile_set.path] = chartfile_set
		return chartfile_set
	end
	function chartRepo:updateChartfileSet(chartfile_set)
		table.insert(actions, {"us", chartfile_set})
		chartfile_sets[chartfile_set.path] = chartfile_set
		return chartfile_set
	end
	function chartRepo:deleteChartfileSets(conds)
		table.insert(actions, {"ds", conds})
	end

	function chartRepo:selectChartfile(path)
		table.insert(actions, {"sc", path})
		return chartfiles[path]
	end
	function chartRepo:insertChartfile(chartfile)
		table.insert(actions, {"ic", chartfile})
		chartfiles[chartfile.path] = chartfile
		return chartfile
	end
	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"uc", chartfile})
		chartfiles[chartfile.path] = chartfile
		return chartfile
	end
	function chartRepo:deleteChartfiles(conds)
		table.insert(actions, {"dc", conds})
	end

	return chartRepo
end

local function get_fake_ncf(files)
	local noteChartFinder = {}
	function noteChartFinder:iter(path)
		local i = 0
		return function()
			i = i + 1
			local v = files[i]
			if v then
				return unpack(v)
			end
		end
	end
	return noteChartFinder
end

function test.all(t)
	local actions = {}
	local chartRepo = get_fake_chartRepo(actions)

	local files = {
		{"related", "chartset", {"a", "b"}, {"a", "b", "c"}},
	}

	local noteChartFinder = get_fake_ncf(files)

	local function get_modtime()
		return 0
	end

	local fsg = FileCacheGenerator(chartRepo, noteChartFinder, get_modtime)
	fsg:lookup("chartset")

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", "chartset"},
		{"is", {
			modified_at = 0,
			path = "chartset"
		}},
		{"sc", "chartset/a"},
		{"ic", {
			modified_at = 0,
			path = "chartset/a"
		}},
		{"sc", "chartset/b"},
		{"ic", {
			modified_at = 0,
			path = "chartset/b"
		}},
		{"dc", {
			dir = "chartset",
			name__notin = {"a", "b", "c"}
		}}
	})
end

return test
