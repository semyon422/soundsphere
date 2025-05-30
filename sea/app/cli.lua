local pkg = require("aqua.pkg")

pkg.import_lua()

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
pcall(pkg.export_love)

require("preload")
local stbl = require("stbl")
local socket = require("socket")
local time_util = require("time_util")
local ComputeContext = require("sea.compute.ComputeContext")

-- lua-nginx-module bug fix
coroutine.wrap = require("icc.co").wrap

local App = require("sea.app.App")
local app_config = require("app_config")
local app = App(app_config)

local domain = app.domain
local chartplays = domain.chartplays
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

function cmds.start_chartplays(state)
	assert(state)
	local time = os.time()
	local total = charts_computer:getChartplaysComputedCount(time, state)
	local task = compute_tasks:createComputeTask(time, "chartplays", state, total)
	cmds.list()
end

function cmds.start_total_rating()
	local total = domain.users:getUsersCount() * leaderboards:getLeaderboardsCount()
	local task = compute_tasks:createComputeTask(os.time(), "total_rating", "new", total)
	cmds.list()
end

function cmds.compute_chartplay(id)
	id = assert(tonumber(id))

	local _chartplay = assert(chartplays:getChartplay(id))
	local _chartdiff = chartplays.charts_repo:getChartdiffByChartdiffKey(_chartplay)

	print("-- Saved chartplay")
	print(stbl.encode(_chartplay))

	print("-- Saved chartdiff")
	if _chartdiff then
		_chartdiff.notes_preview = "hidden"
		print(stbl.encode(_chartdiff))
	else
		print("missing")
	end

	local compute_data_loader = domain.compute_data_loader

	local chart_file_data = assert(compute_data_loader:requireChart(_chartplay.hash))
	local replay_and_data = assert(compute_data_loader:requireReplay(_chartplay.replay_hash))

	local ctx = ComputeContext()

	assert(ctx:fromFileData(
		chart_file_data.name,
		chart_file_data.data,
		_chartplay.index
	))

	local replay = replay_and_data.replay

	ctx:applyModifierReorder(replay)

	local chartdiff = ctx:computeBase(replay)
	chartdiff.notes_preview = "hidden"

	local chartplay_computed = assert(ctx:computeReplay(replay))

	-- chartplay:importChartplayBase(replay)
	-- chartplay:importChartplayComputed(chartplay_computed)

	print("-- Computed chartplay")
	print(stbl.encode(chartplay_computed))

	print("-- Computed chartdiff")
	print(stbl.encode(chartdiff))
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

function cmds.chartplays_count()
	-- app.app_db.db:query([[
	-- 	UPDATE users
	-- 	SET chartplays_count = 0
	-- ]])
	app.app_db.db:query([[
		UPDATE users
		SET chartplays_count = chartplays.count
		FROM (
			SELECT
				COUNT(*) AS count,
				user_id
			FROM chartplays
			GROUP BY user_id
		) AS chartplays
		WHERE chartplays.user_id = users.id
	]])
end

function cmds.play_time()
	-- app.app_db.db:query([[
	-- 	UPDATE users
	-- 	SET play_time = 0
	-- ]])
	app.app_db.db:query([[
		UPDATE users
		SET play_time = duration
		FROM (
			SELECT
				SUM(1000.0 * chartdiffs.duration / chartdiffs.rate) AS duration,
				user_id
			FROM chartplays
			INNER JOIN chartdiffs ON
				chartplays.hash = chartdiffs.hash AND
				chartplays.`index` = chartdiffs.`index` AND
				chartplays.modifiers = chartdiffs.modifiers AND
				chartplays.rate = chartdiffs.rate AND
				chartplays.mode = chartdiffs.mode
			GROUP BY user_id
		) AS chartplays
		WHERE users.id == user_id
	]])
end

function cmds.chartmetas_count()
	-- app.app_db.db:query([[
	-- 	UPDATE users
	-- 	SET chartmetas_count = 0
	-- ]])
	app.app_db.db:query([[
		UPDATE users
		SET chartmetas_count = count
		FROM (
			SELECT
				COUNT(*) OVER (PARTITION BY user_id) AS count,
				user_id
			FROM chartplays
			INNER JOIN chartmetas ON
				chartplays.hash = chartmetas.hash AND
				chartplays.`index` = chartmetas.`index`
			GROUP BY chartmetas.id
		) AS chartplays
		WHERE users.id == user_id
	]])
end

function cmds.auth_codes()
	local codes = app.app_db.db:query([[
		SELECT
			auth_codes.code,
			auth_codes.type,
			users.id,
			users.name,
			users.email
		FROM auth_codes
		INNER JOIN users ON
			users.id = auth_codes.user_id
		WHERE
			auth_codes.used = 0
		;
	]])

	for _, c in ipairs(codes) do
		print(c.code, tonumber(c.id), c.name, c.email)
	end
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

function cmds.migrate()
	local ServerMigration = require("sea.storage.old_server.ServerMigration")
	local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
	local RestyMysqlDatabase = require("rdb.db.RestyMysqlDatabase")
	local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

	local src_db = RestyMysqlDatabase()
	src_db:open("backend", "username", "password", "127.0.0.1", 3306)

	local dst_db = ServerSqliteDatabase(LjsqliteDatabase())
	dst_db.path = "server.db"
	dst_db:open()

	dst_db.db:exec("BEGIN")
	local mig = ServerMigration(src_db, dst_db.db)
	mig:migrate()
	dst_db.db:exec("COMMIT")
end

local command = arg[1]
local f = cmds[command]
if f then
	app:load()
	f(unpack(arg, 2))
else
	print("unknown command")
end
