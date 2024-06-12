local table_util = require("table_util")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")

local test = {}

local function get_hi(hash, index)
	if type(hash) == "table" then
		return hash.hash .. "/" .. hash.index
	end
	return hash .. "/" .. index
end

local function get_fake_chartRepo(actions, chartfiles, chartmetas)
	local chartRepo = {}

	function chartRepo:selectUnhashedChartfiles()
		local cfs = {}
		for _, cf in pairs(chartfiles) do
			if not cf.hash then
				table.insert(cfs, cf)
			end
		end
		table.sort(cfs, function(a, b)
			return a.path < b.path
		end)
		return cfs
	end
	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"uc", table_util.deepcopy(chartfile)})
		chartfiles[chartfile.path] = chartfile
		return chartfile
	end
	function chartRepo:selectChartmeta(hash, index)
		table.insert(actions, {"sm", hash, index})
		return chartmetas[get_hi(hash, index)]
	end
	function chartRepo:insertChartmeta(chartmeta)
		table.insert(actions, {"im", table_util.deepcopy(chartmeta)})
		chartmetas[get_hi(chartmeta)] = chartmeta
		return chartmeta
	end
	function chartRepo:updateChartmeta(chartmeta)
		table.insert(actions, {"um", table_util.deepcopy(chartmeta)})
		chartmetas[get_hi(chartmeta)] = chartmeta
		return chartmeta
	end

	return chartRepo
end

local function get_fs(items)
	local fs = {}
	function fs.read(path)
		return items[path]
	end
	return fs
end

function test.all(t)
	local chartfiles = {  -- unhashed_chartfiles
		["charts/a"] = {
			path = "charts/a",
		},
		["charts/b"] = {
			path = "charts/b",
		},
	}

	local actions, chartmetas = {}, {}
	local chartRepo = get_fake_chartRepo(actions, chartfiles, chartmetas)

	local items = {
		["charts/a"] = "content",
		["charts/b"] = "content",
	}
	local fs = get_fs(items)

	local chart_error
	local function getCharts(path, content)
		if chart_error then
			return nil, chart_error
		end
		return {{chartmeta = {}}}
	end

	local cg = ChartmetaGenerator(chartRepo, chartRepo, {getCharts = getCharts})

	t:eq(cg:generate(chartfiles["charts/a"], "content"), "cached")
	t:eq(cg:generate(chartfiles["charts/b"], "content"), "reused")

	chartfiles["charts/a"].hash = nil
	t:eq(cg:generate(chartfiles["charts/a"], "content"), "reused")
	t:assert(chartfiles["charts/a"].hash)

	chartfiles["charts/a"].hash = nil
	t:eq(cg:generate(chartfiles["charts/a"], "content", true), "cached")
	t:assert(chartfiles["charts/a"].hash)

	chart_error = "err"
	chartfiles["charts/a"].hash = nil
	local ok, actual_error = cg:generate(chartfiles["charts/a"], "content", true)
	t:eq(ok, nil)
	t:eq(actual_error, chart_error)
	t:assert(not chartfiles["charts/a"].hash)

	-- print(require("inspect")(actions))
	t:tdeq(actions, {
		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"im", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			index = 1,
		}},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},
		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/b",
		}},

		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},

		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"um", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			index = 1,
		}},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},
	})
end

return test
