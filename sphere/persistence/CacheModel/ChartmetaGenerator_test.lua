local table_util = require("table_util")
local ChartmetaGenerator = require("sphere.persistence.CacheModel.ChartmetaGenerator")

local test = {}

local function get_path(dir, name)
	if type(dir) == "table" then
		return dir.dir .. "/" .. dir.name
	end
	return dir .. "/" .. name
end
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
			return get_path(a) < get_path(b)
		end)
		return cfs
	end
	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"uc", table_util.deepcopy(chartfile)})
		chartfiles[get_path(chartfile)] = chartfile
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
	local chartfiles = {
		["charts/a"] = {
			dir = "charts",
			name = "a",
		},
		["charts/b"] = {
			dir = "charts",
			name = "b",
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
	local function getNoteCharts(path, content)
		if chart_error then
			return nil, chart_error
		end
		return {{chartmeta = {}}}
	end

	local cg = ChartmetaGenerator(chartRepo, {getNoteCharts = getNoteCharts}, fs)

	cg.after = function() return true end

	cg:generate(false)

	t:eq(cg.cached, 1)
	t:eq(cg.reused, 0)

	cg:generate(false)

	t:eq(cg.cached, 1)
	t:eq(cg.reused, 1)

	cg.after = function() return false end

	chartfiles["charts/a"].hash = nil
	cg:generate(false)
	t:eq(cg.reused, 2)
	t:assert(chartfiles["charts/a"].hash)

	chartfiles["charts/a"].hash = nil
	cg:generate(true)
	t:eq(cg.cached, 2)
	t:assert(chartfiles["charts/a"].hash)

	chart_error = "err"
	local actual_chartfile, actual_error
	chartfiles["charts/a"].hash = nil
	cg.error_handler = function(chartfile, err)
		actual_chartfile = chartfile
		actual_error = err
	end
	cg:generate(true)
	t:eq(cg.cached, 2)
	t:eq(actual_error, chart_error)
	t:eq(actual_chartfile, chartfiles["charts/a"])
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
			dir = "charts",
			name = "a",
		}},
		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"uc", {
			dir = "charts",
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			name = "b",
		}},

		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			dir = "charts",
			name = "a",
		}},

		{"sm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"um", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			index = 1,
		}},
		{"uc", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			dir = "charts",
			name = "a",
		}},
	})
end

return test
