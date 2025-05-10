local pkg = require("aqua.pkg")

pkg.addc()
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.addc("tree/lib/lua/5.1")
pkg.add()
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")

pkg.export_lua()

require("preload")
local stbl = require("stbl")
local socket = require("socket")
local time_util = require("time_util")

-- lua-nginx-module bug fix
coroutine.wrap = require("icc.co").wrap

local App = require("sea.app.App")
local app_config = require("app_config")
local app = App(app_config)
app:load()

local domain = app.domain
local compute_processor = domain.compute_processor
local charts_computer = domain.charts_computer

local cmds = {}

function cmds.run(id)
	local start_time = socket.gettime()
	local count = 0

	id = assert(tonumber(id))
	local proc = assert(compute_processor:getComputeProcess(id))
	assert(proc.target == "chartplays")

	local chartplays = charts_computer:getChartplaysComputed(proc.created_at, proc.state, 10)
	while #chartplays > 0 do
		proc = compute_processor:step(proc, chartplays)
		count = count + #chartplays
		local dt = socket.gettime() - start_time
		local speed = count / dt
		print(("%s / %s - %0.2f rps - %s / %s - %0.2f%%"):format(
			time_util.format(dt),
			time_util.format((proc.total - proc.current) / speed),
			speed,
			proc.current,
			proc.total,
			proc.current / proc.total * 100
		))
		chartplays = charts_computer:getChartplaysComputed(proc.created_at, proc.state, 10)
	end

	print("done")
end

function cmds.start_chartplays()
	local time = os.time()
	local total = charts_computer:getChartplaysComputedCount(time, "new")
	local proc = compute_processor:startChartplays(os.time(), "new", total)
	cmds.list()
end

function cmds.delete(id)
	id = assert(tonumber(id))
	compute_processor:deleteProcess(id)
	cmds.list()
end

function cmds.list()
	local cps = compute_processor:getComputeProcesses()
	print("Compute processes:")
	for _, cp in ipairs(cps) do
		print(stbl.encode(cp))
	end
end

local command = arg[1]
local f = cmds[command]
if f then
	f(unpack(arg, 2))
else
	print("unknown command")
end
