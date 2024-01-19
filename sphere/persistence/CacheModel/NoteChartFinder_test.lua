local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")

local test = {}

local function get_files()
	local items = {
		["root"] = {
			type = "directory",
			"rel_charts",
			"unrel_charts",
		},
		["root/rel_charts"] = {
			type = "directory",
			"chartset",
		},
		["root/rel_charts/chartset"] = {
			type = "directory",
			"chart.osu",
		},
		["root/rel_charts/chartset/chart.osu"] = {
			type = "file",
		},
		["root/unrel_charts"] = {
			type = "directory",
			"chart.ojn",
		},
		["root/unrel_charts/chart.ojn"] = {
			type = "file",
		},
	}
	local function checkDir(path)
		return not items[path].cached
	end
	local function checkFile(path)
		return not items[path].cached
	end
	local fs = {}
	function fs.getDirectoryItems(path)
		return items[path]
	end
	function fs.getInfo(path)
		return items[path]
	end

	local ncf = NoteChartFinder(checkDir, checkFile, fs)
	local iterator = ncf:newFileIterator("root")

	return items, iterator
end

local function iter(iterator)
	local chartset_dirs = {}
	local chart_files = {}

	local _dir
	for path, dir in iterator do
		if dir ~= _dir then
			_dir = dir
			table.insert(chartset_dirs, dir)
		end
		table.insert(chart_files, path)
	end

	return chartset_dirs, chart_files
end

function test.not_cached(t)
	local items, iterator = get_files()
	local chartset_dirs, chart_files = iter(iterator)

	t:teq(chartset_dirs, {
		"root/rel_charts/chartset",
		"root/unrel_charts/chart.ojn",
	})
	t:teq(chart_files, {
		"root/rel_charts/chartset/chart.osu",
		"root/unrel_charts/chart.ojn",
	})
end

function test.chartsets_cached(t)
	local items, iterator = get_files()
	items["root/rel_charts/chartset"].cached = true
	items["root/unrel_charts/chart.ojn"].cached = true

	local chartset_dirs, chart_files = iter(iterator)

	t:teq(chartset_dirs, {})
	t:teq(chart_files, {})
end

function test.new_charts(t)
	local items, iterator = get_files()
	items["root/rel_charts/chartset/chart.osu"].cached = true
	items["root/unrel_charts/chart.ojn"].cached = true

	items["root/rel_charts/chartset/chart2.osu"] = {type = "file"}
	table.insert(items["root/rel_charts/chartset"], "chart2.osu")

	items["root/unrel_charts/chart2.ojn"] = {type = "file"}
	table.insert(items["root/unrel_charts"], "chart2.ojn")

	local chartset_dirs, chart_files = iter(iterator)

	t:teq(chartset_dirs, {
		"root/rel_charts/chartset",
		"root/unrel_charts/chart2.ojn",
	})
	t:teq(chart_files, {
		"root/rel_charts/chartset/chart2.osu",
		"root/unrel_charts/chart2.ojn",
	})
end

return test
