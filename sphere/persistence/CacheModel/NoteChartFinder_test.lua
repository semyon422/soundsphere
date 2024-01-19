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
	local iterator = ncf:iter("root")

	return items, iterator
end

local function iter(iterator)
	local chartfile_sets = {}
	local chartfiles = {}

	for typ, dir, checked_items, all_items in iterator do
		if typ == "related" then
			table.insert(chartfile_sets, dir)
			for _, item in ipairs(checked_items) do
				table.insert(chartfiles, dir .. "/" .. item)
			end
		elseif typ == "unrelated" then
			for _, item in ipairs(checked_items) do
				table.insert(chartfile_sets, dir .. "/" .. item)
				table.insert(chartfiles, dir .. "/" .. item)
			end
		end
	end

	return chartfile_sets, chartfiles
end

function test.not_cached(t)
	local items, iterator = get_files()
	local chartfile_sets, chartfiles = iter(iterator)

	t:teq(chartfile_sets, {
		"root/rel_charts/chartset",
		"root/unrel_charts/chart.ojn",
	})
	t:teq(chartfiles, {
		"root/rel_charts/chartset/chart.osu",
		"root/unrel_charts/chart.ojn",
	})
end

function test.chartsets_cached(t)
	local items, iterator = get_files()
	items["root/rel_charts/chartset"].cached = true
	items["root/unrel_charts/chart.ojn"].cached = true

	local chartfile_sets, chartfiles = iter(iterator)

	t:teq(chartfile_sets, {})
	t:teq(chartfiles, {})
end

function test.new_charts(t)
	local items, iterator = get_files()
	items["root/rel_charts/chartset/chart.osu"].cached = true
	items["root/unrel_charts/chart.ojn"].cached = true

	items["root/rel_charts/chartset/chart2.osu"] = {type = "file"}
	table.insert(items["root/rel_charts/chartset"], "chart2.osu")

	items["root/unrel_charts/chart2.ojn"] = {type = "file"}
	table.insert(items["root/unrel_charts"], "chart2.ojn")

	local chartfile_sets, chartfiles = iter(iterator)

	t:teq(chartfile_sets, {
		"root/rel_charts/chartset",
		"root/unrel_charts/chart2.ojn",
	})
	t:teq(chartfiles, {
		"root/rel_charts/chartset/chart2.osu",
		"root/unrel_charts/chart2.ojn",
	})
end

return test
