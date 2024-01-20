local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")

local test = {}

local function get_path(dir, name)
	if type(dir) == "table" then
		return dir.dir .. "/" .. dir.name
	end
	return dir .. "/" .. name
end

local function get_fake_chartRepo(actions, chartfiles, chartfile_sets)
	local chartRepo = {}

	function chartRepo:selectChartfileSet(dir, name)
		table.insert(actions, {"ss", dir, name})
		return chartfile_sets[get_path(dir, name)]
	end
	function chartRepo:insertChartfileSet(chartfile_set)
		table.insert(actions, {"is", chartfile_set})
		chartfile_sets[get_path(chartfile_set)] = chartfile_set
		return chartfile_set
	end
	function chartRepo:updateChartfileSet(chartfile_set)
		table.insert(actions, {"us", chartfile_set})
		chartfile_sets[get_path(chartfile_set)] = chartfile_set
		return chartfile_set
	end
	function chartRepo:deleteChartfileSets(conds)
		table.insert(actions, {"ds", conds})
	end

	function chartRepo:selectChartfile(dir, name)
		table.insert(actions, {"sc", dir, name})
		return chartfiles[get_path(dir, name)]
	end
	function chartRepo:insertChartfile(chartfile)
		table.insert(actions, {"ic", chartfile})
		chartfiles[get_path(chartfile)] = chartfile
		return chartfile
	end
	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"uc", chartfile})
		chartfiles[get_path(chartfile)] = chartfile
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

function test.rel_root(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"related_dir", ".", "chartset", 0},
		{"related", "chartset", "a", 1},
		{"related", "chartset", "b", 2},
		-- {"related", "chartset", "c", 3},
		{"related_all", "chartset", {"a", "b", "c"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder)
	fcg:lookup("chartset")

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", ".", "chartset"},
		{"is", {
			modified_at = 0,
			dir = ".",
			name = "chartset",
		}},
		{"sc", "chartset", "a"},
		{"ic", {
			modified_at = 1,
			dir = "chartset",
			name = "a",
		}},
		{"sc", "chartset", "b"},
		{"ic", {
			modified_at = 2,
			dir = "chartset",
			name = "b",
		}},
		{"dc", {
			dir = "chartset",
			name__notin = {"a", "b", "c"}
		}},
	})
end

function test.unrel_root(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"unrelated_dir", ".", "charts", 0},
		{"unrelated", "charts", "a", 1},
		{"unrelated", "charts", "b", 2},
		-- {"unrelated", "charts", "c", 3},
		{"unrelated_all", "charts", {"a", "b", "c"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder)
	fcg:lookup("charts")

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", "charts", "a"},
		{"is", {
			modified_at = 1,
			dir = "charts",
			name = "a",
		}},
		{"sc", "charts", "a"},
		{"ic", {
			modified_at = 1,
			dir = "charts",
			name = "a",
		}},
		{"ss", "charts", "b"},
		{"is", {
			modified_at = 2,
			dir = "charts",
			name = "b",
		}},
		{"sc", "charts", "b"},
		{"ic", {
			modified_at = 2,
			dir = "charts",
			name = "b",
		}},
		{"dc", {
			dir = "charts",
			name__notin = {"a", "b", "c"}
		}},
		{"ds", {
			dir = "charts",
			name__notin = {"a", "b", "c"}
		}},
	})
end

function test.complex(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"directory_dir", ".", "root", 0},
		{"directory", "root", "osucharts", 0},
		{"directory", "root", "jamcharts", 0},
		{"directory_all", "root", {"osucharts", "jamcharts"}, 0},

		{"directory_dir", "root", "osucharts", 0},
		{"directory", "root/osucharts", "chartset1", 0},
		{"directory", "root/osucharts", "chartset2", 0},
		{"directory_all", "root/osucharts", {"chartset1", "chartset2"}, 0},

		{"related_dir", "root/osucharts", "chartset1", 0},
		{"related", "root/osucharts/chartset1", "a", 0},
		{"related", "root/osucharts/chartset1", "b", 0},
		{"related_all", "root/osucharts/chartset1", {"a", "b"}, 0},

		{"related_dir", "root/osucharts", "chartset2", 0},
		{"related", "root/osucharts/chartset2", "a", 0},
		{"related", "root/osucharts/chartset2", "b", 0},
		{"related_all", "root/osucharts/chartset2", {"a", "b"}, 0},

		{"unrelated_dir", "root", "jamcharts", 0},
		{"unrelated", "root/jamcharts", "a", 0},
		{"unrelated", "root/jamcharts", "b", 0},
		{"unrelated_all", "root/jamcharts", {"a", "b"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder)
	fcg:lookup("charts")
	-- print(require("inspect")(actions))

	t:tdeq(actions, {
		{"ss", "root", "osucharts"},
		{"ss", "root", "jamcharts"},
		{"ds", {
			dir = "root",
			name__notin = {"osucharts", "jamcharts"}
		}},
		{"ss", "root/osucharts", "chartset1"},
		{"ss", "root/osucharts", "chartset2"},
		{"ds", {
			dir = "root/osucharts",
			name__notin = {"chartset1", "chartset2"}
		}},
		{"ss", "root/osucharts", "chartset1"},
		{"is", {
			modified_at = 0,
			dir = "root/osucharts",
			name = "chartset1",
		}},
		{"sc", "root/osucharts/chartset1", "a"},
		{"ic", {
			modified_at = 0,
			dir = "root/osucharts/chartset1",
			name = "a",
		}},
		{"sc", "root/osucharts/chartset1", "b"},
		{"ic", {
			modified_at = 0,
			dir = "root/osucharts/chartset1",
			name = "b",
		}},
		{"dc", {
			dir = "root/osucharts/chartset1",
			name__notin = {"a", "b"}
		}},
		{"ss", "root/osucharts", "chartset2"},
		{"is", {
			modified_at = 0,
			dir = "root/osucharts",
			name = "chartset2",
		}},
		{"sc", "root/osucharts/chartset2", "a"},
		{"ic", {
			modified_at = 0,
			dir = "root/osucharts/chartset2",
			name = "a",
		}},
		{"sc", "root/osucharts/chartset2", "b"},
		{"ic", {
			modified_at = 0,
			dir = "root/osucharts/chartset2",
			name = "b",
		}},
		{"dc", {
			dir = "root/osucharts/chartset2",
			name__notin = {"a", "b"}
		}},
		{"ss", "root/jamcharts", "a"},
		{"is", {
			modified_at = 0,
			dir = "root/jamcharts",
			name = "a",
		}},
		{"sc", "root/jamcharts", "a"},
		{"ic", {
			modified_at = 0,
			dir = "root/jamcharts",
			name = "a",
		}},
		{"ss", "root/jamcharts", "b"},
		{"is", {
			modified_at = 0,
			dir = "root/jamcharts",
			name = "b",
		}},
		{"sc", "root/jamcharts", "b"},
		{"ic", {
			modified_at = 0,
			dir = "root/jamcharts",
			name = "b",
		}},
		{"dc", {
			dir = "root/jamcharts",
			name__notin = {"a", "b"}
		}},
		{"ds", {
			dir = "root/jamcharts",
			name__notin = {"a", "b"}
		}}
	})

	actions = {}
	chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	files = {
		{"directory_dir", "root", "", 0},
		{"directory", "root", "osucharts", 0},
		{"directory", "root", "jamcharts", 0},
		{"directory_all", "root", {"osucharts", "jamcharts"}, 0},

		{"directory_dir", "root/osucharts", "", 0},
		{"directory_all", "root/osucharts", {"chartset1", "chartset2"}, 0},
	}

	noteChartFinder = get_fake_ncf(files)

	fcg = FileCacheGenerator(chartRepo, noteChartFinder)

	fcg:lookup("charts")
	-- print(require("inspect")(actions))

	t:tdeq(actions, {
		{"ss", "root", "osucharts"},
		{"ss", "root", "jamcharts"},
		{"ds", {
			dir = "root",
			name__notin = {"osucharts", "jamcharts"}
		}},
		{"ds", {
			dir = "root/osucharts",
			name__notin = {"chartset1", "chartset2"}
		}}
	})
end

return test
