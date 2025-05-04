local table_util = require("table_util")
local digest = require("digest")
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

	function chartRepo:updateChartfile(chartfile)
		table.insert(actions, {"ucf", table_util.deepcopy(chartfile)})
		chartfiles[chartfile.path] = chartfile
		return chartfile
	end
	function chartRepo:getChartmetaByHashIndex(hash, index)
		table.insert(actions, {"gcm", hash, index})
		return chartmetas[get_hi(hash, index)]
	end
	function chartRepo:createUpdateChartmeta(chartmeta)
		table.insert(actions, {"cucm", table_util.deepcopy(chartmeta)})
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
	local chartfiles = { -- unhashed_chartfiles
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
	local function getCharts(_, path, content, hash)
		if chart_error then
			return nil, chart_error
		end
		return {{chart = {}, chartmeta = {hash = digest.hash("md5", content, true), index = 1}}}
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
		{"gcm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"cucm", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			index = 1,
		}},
		{"ucf", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},
		{"gcm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"ucf", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/b",
		}},

		{"gcm", "9a0364b9e99bb480dd25e1f0284c8555", 1},
		{"ucf", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},

		{"cucm", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			index = 1,
		}},
		{"ucf", {
			hash = "9a0364b9e99bb480dd25e1f0284c8555",
			path = "charts/a",
		}},
	})
end

return test
