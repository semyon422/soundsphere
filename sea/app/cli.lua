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
local compute_tasks = domain.compute_tasks
local charts_computer = domain.charts_computer
local leaderboards = domain.leaderboards

local function run_chartplays(task)
	local start_time = socket.gettime()
	local count = 0

	local chartplays = charts_computer:getChartplaysComputed(task.created_at, task.state, 10)
	while #chartplays > 0 do
		for _, chartplay in ipairs(chartplays) do
			local ret, err = charts_computer:computeChartplay(chartplay)
			if not ret then
				print(err)
			end
		end

		task = compute_tasks:step(task, #chartplays)
		chartplays = charts_computer:getChartplaysComputed(task.created_at, task.state, 10)

		count = count + #chartplays
		local dt = socket.gettime() - start_time
		local speed = count / dt
		print(("%s / %s - %0.2f rps - %s / %s - %0.2f%%"):format(
			time_util.format(dt),
			time_util.format((task.total - task.current) / speed),
			speed,
			task.current,
			task.total,
			task.current / task.total * 100
		))
	end
end

local function run_total_rating(task)
	local lbs = domain.leaderboards:getLeaderboards()
	local users = domain.users:getUsers()

	for i, user in ipairs(users) do
		for _, lb in ipairs(lbs) do
			-- task = compute_tasks:step(task, user, lb)
			leaderboards:updateLeaderboardUser(lb, user.id, true)
		end
		print(i)
	end
end

local cmds = {}

function cmds.run(id)
	id = assert(tonumber(id))
	local task = assert(compute_tasks:getComputeTask(id))
	if task.target == "chartplays" then
		run_chartplays(task)
	elseif task.target == "total_rating" then
		run_total_rating(task)
	end

	print("done")
end

function cmds.start_chartplays()
	local time = os.time()
	local total = charts_computer:getChartplaysComputedCount(time, "new")
	local task = compute_tasks:Compute(time, "chartplays", "new", total)
	cmds.list()
end

function cmds.start_total_rating()
	local total = domain.users:getUsersCount() * leaderboards:getLeaderboardsCount()
	local task = compute_tasks:Compute(os.time(), "total_rating", "new", total)
	cmds.list()
end

function cmds.ranks()
	app.app_db.db:query([[
		UPDATE leaderboard_users
		SET rank = lb_users.rank
		FROM (
			SELECT
			ROW_NUMBER() OVER (PARTITION BY leaderboard_id ORDER BY total_rating DESC) AS rank,
			id
			FROM leaderboard_users
		) AS lb_users
		WHERE leaderboard_users.id = lb_users.id
	]])
end

function cmds.delete(id)
	id = assert(tonumber(id))
	compute_tasks:deleteProcess(id)
	cmds.list()
end

function cmds.list()
	local cps = compute_tasks:getComputeTasks()
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
