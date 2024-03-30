local sql_util = require("rdb.sql_util")
local path_util = require("path_util")
local FileCacheGenerator = require("sphere.persistence.CacheModel.FileCacheGenerator")

local test = {}

local function get_fake_chartRepo(actions, chartfiles, chartfile_sets)
	local chartRepo = {}

	local file_id, set_id = 0, 0

	function chartRepo:selectChartfileSet(dir, name, location_id)
		table.insert(actions, {"ss", dir, name})
		return chartfile_sets[path_util.join(dir, name)]
	end
	function chartRepo:insertChartfileSet(chartfile_set)
		table.insert(actions, {"is", chartfile_set})
		chartfile_sets[path_util.join(chartfile_set.dir, chartfile_set.name)] = chartfile_set
		set_id = set_id + 1
		chartfile_set.id = set_id
		return chartfile_set
	end
	function chartRepo:updateChartfileSet(chartfile_set)
		table.insert(actions, {"us", chartfile_set})
		chartfile_sets[path_util.join(chartfile_set.dir, chartfile_set.name)] = chartfile_set
		return chartfile_set
	end
	function chartRepo:deleteChartfileSets(conds)
		table.insert(actions, {"ds", conds})
	end

	function chartRepo:selectChartfile(set_id, name)
		table.insert(actions, {"sc", set_id, name})
		return chartfiles[path_util.join(set_id, name)]
	end
	function chartRepo:insertChartfile(chartfile)
		table.insert(actions, {"ic", chartfile})
		chartfiles[path_util.join(chartfile.set_id, chartfile.name)] = chartfile
		file_id = file_id + 1
		chartfile.id = file_id
		return chartfile
	end
	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"uc", chartfile})
		chartfiles[path_util.join(chartfile.set_id, chartfile.name)] = chartfile
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
		{"related_dir", nil, "chartset", 0},
		{"related", "chartset", "a", 1},
		{"related", "chartset", "b", 2},
		-- {"related", "chartset", "c", 3},
		{"related_all", "chartset", {"a", "b", "c"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)
	fcg:lookup("chartset", 1, nil)

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", nil, "chartset"},
		{"is", {
			id = 1,
			modified_at = 0,
			dir = nil,
			name = "chartset",
			is_file = false,
			location_id = 1,
		}},
		{"sc", 1, "a"},
		{"ic", {
			id = 1,
			modified_at = 1,
			set_id = 1,
			name = "a",
		}},
		{"sc", 1, "b"},
		{"ic", {
			id = 2,
			modified_at = 2,
			set_id = 1,
			name = "b",
		}},
		{"dc", {
			set_id = 1,
			name__notin = {"a", "b", "c"},
		}},
	})
end

function test.rel_root_noname_invalid(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"related_dir", nil, nil, 0},
		{"related", nil, "a", 1},
		{"related_all", nil, {"a"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)
	fcg:lookup("chartset", 1, nil)

	t:tdeq(actions, {})
end

function test.unrel_root(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"unrelated_dir", nil, "charts", 0},
		{"unrelated", "charts", "a", 1},
		{"unrelated", "charts", "b", 2},
		-- {"unrelated", "charts", "c", 3},
		{"unrelated_all", "charts", {"a", "b", "c"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)
	fcg:lookup("charts", 1, nil)

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", "charts", "a"},
		{"is", {
			id = 1,
			modified_at = 1,
			dir = "charts",
			name = "a",
			is_file = true,
			location_id = 1,
		}},
		{"sc", 1, "a"},
		{"ic", {
			id = 1,
			modified_at = 1,
			set_id = 1,
			name = "a",
		}},
		{"ss", "charts", "b"},
		{"is", {
			id = 2,
			modified_at = 2,
			dir = "charts",
			name = "b",
			is_file = true,
			location_id = 1,
		}},
		{"sc", 2, "b"},
		{"ic", {
			id = 2,
			modified_at = 2,
			set_id = 2,
			name = "b",
		}},
		{"dc", {
			set_id = 2,
			name__notin = {"a", "b", "c"},
		}},
		{"ds", {
			dir = "charts",
			dir__isnull = false,
			name__notin = {"a", "b", "c"},
			location_id = 1,
		}},
	})
end

function test.root_packs(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	-- prefix ~= nil and dir == nil
	local files = {
		{"directory_dir", nil, nil, 0},
		{"directory", nil, "osucharts", 0},
		{"directory", nil, "jamcharts", 0},
		{"directory_all", nil, {"osucharts", "jamcharts"}, 0},
	}

	local noteChartFinder = get_fake_ncf(files)

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)
	fcg:lookup("charts", 1, nil)

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"ss", nil, "osucharts"},
		{"ss", nil, "jamcharts"},
		{"ds", {
			dir__isnull = true,
			location_id = 1,
			name__notin = {"osucharts", "jamcharts"},
		}}
	})
end

function test.complex(t)
	local actions, chartfiles, chartfile_sets = {}, {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	local files = {
		{"directory_dir", nil, "root", 0},
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

	local fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)
	fcg:lookup("charts", 1, nil)
	-- print(require("inspect")(actions))

	t:tdeq(actions, {
		{"ss", "root", "osucharts"},
		{"ss", "root", "jamcharts"},
		{"ds", {
			dir = "root",
			dir__isnull = false,
			name__notin = {"osucharts", "jamcharts"},
			location_id = 1,
		}},
		{"ss", "root/osucharts", "chartset1"},
		{"ss", "root/osucharts", "chartset2"},
		{"ds", {
			dir = "root/osucharts",
			dir__isnull = false,
			name__notin = {"chartset1", "chartset2"},
			location_id = 1,
		}},
		{"ss", "root/osucharts", "chartset1"},
		{"is", {
			id = 1,
			modified_at = 0,
			dir = "root/osucharts",
			name = "chartset1",
			is_file = false,
			location_id = 1,
		}},
		{"sc", 1, "a"},
		{"ic", {
			id = 1,
			modified_at = 0,
			set_id = 1,
			name = "a",
		}},
		{"sc", 1, "b"},
		{"ic", {
			id = 2,
			modified_at = 0,
			set_id = 1,
			name = "b",
		}},
		{"dc", {
			set_id = 1,
			name__notin = {"a", "b"}
		}},
		{"ss", "root/osucharts", "chartset2"},
		{"is", {
			id = 2,
			modified_at = 0,
			dir = "root/osucharts",
			name = "chartset2",
			is_file = false,
			location_id = 1,
		}},
		{"sc", 2, "a"},
		{"ic", {
			id = 3,
			modified_at = 0,
			set_id = 2,
			name = "a",
		}},
		{"sc", 2, "b"},
		{"ic", {
			id = 4,
			modified_at = 0,
			set_id = 2,
			name = "b",
		}},
		{"dc", {
			set_id = 2,
			name__notin = {"a", "b"}
		}},
		{"ss", "root/jamcharts", "a"},
		{"is", {
			id = 3,
			modified_at = 0,
			dir = "root/jamcharts",
			name = "a",
			is_file = true,
			location_id = 1,
		}},
		{"sc", 3, "a"},
		{"ic", {
			id = 5,
			modified_at = 0,
			set_id = 3,
			name = "a",
		}},
		{"ss", "root/jamcharts", "b"},
		{"is", {
			id = 4,
			modified_at = 0,
			dir = "root/jamcharts",
			name = "b",
			is_file = true,
			location_id = 1,
		}},
		{"sc", 4, "b"},
		{"ic", {
			id = 6,
			modified_at = 0,
			set_id = 4,
			name = "b",
		}},
		{"dc", {
			set_id = 4,
			name__notin = {"a", "b"}
		}},
		{"ds", {
			dir = "root/jamcharts",
			dir__isnull = false,
			name__notin = {"a", "b"},
			location_id = 1,
		}}
	})

	actions = {}
	chartRepo = get_fake_chartRepo(actions, chartfiles, chartfile_sets)

	files = {
		{"directory_dir", nil, "root", 0},
		{"directory", "root", "osucharts", 0},
		{"directory", "root", "jamcharts", 0},
		{"directory_all", "root", {"osucharts", "jamcharts"}, 0},

		{"directory_dir", "root", "osucharts", 0},
		{"directory_all", "root/osucharts", {"chartset1", "chartset2"}, 0},
	}

	noteChartFinder = get_fake_ncf(files)

	fcg = FileCacheGenerator(chartRepo, noteChartFinder, function() end)

	fcg:lookup("charts", 1, nil)

	t:assert(not fcg:shouldScan("root/osucharts", "chartset1", 0))
	t:assert(fcg:shouldScan("root/osucharts", "chartset1", 1))
	fcg:processChartfileSet({
		dir = "root/osucharts",
		name = "chartset1",
		modified_at = 0,
		is_file = false,
		location_id = 1,
	})
	fcg:processChartfileSet({
		dir = "root/osucharts",
		name = "chartset1",
		modified_at = 1,
		is_file = false,
		location_id = 1,
	})
	fcg:processChartfile(1, "a", 0)
	fcg:processChartfile(1, "a", 1)
	-- print(require("inspect")(actions))

	t:tdeq(actions, {
		{"ss", "root", "osucharts"},
		{"ss", "root", "jamcharts"},
		{"ds", {
			dir = "root",
			dir__isnull = false,
			name__notin = {"osucharts", "jamcharts"},
			location_id = 1,
		}},
		{"ds", {
			dir = "root/osucharts",
			dir__isnull = false,
			name__notin = {"chartset1", "chartset2"},
			location_id = 1,
		}},

		{"ss", "root/osucharts", "chartset1"},
		{"ss", "root/osucharts", "chartset1"},

		{"ss", "root/osucharts", "chartset1"},
		{"ss", "root/osucharts", "chartset1"},
		{"us", {
			id = 1,
			modified_at = 1,
			dir = "root/osucharts",
			name = "chartset1",
			is_file = false,
			location_id = 1,
		}},

		{"sc", 1, "a"},
		{"sc", 1, "a"},
		{"uc", {
			id = 1,
			modified_at = 1,
			hash = sql_util.NULL,
			set_id = 1,
			name = "a",
		}},
	})
end

return test
