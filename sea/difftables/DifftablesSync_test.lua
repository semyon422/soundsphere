local DifftablesSync = require("sea.difftables.DifftablesSync")
local DifftablesServerRemote = require("sea.difftables.remotes.DifftablesServerRemote")
local DifftablesServerRemoteValidation = require("sea.difftables.remotes.DifftablesServerRemoteValidation")
local Difftables = require("sea.difftables.Difftables")
local Difftable = require("sea.difftables.Difftable")
local DifftableChartmeta = require("sea.difftables.DifftableChartmeta")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

local table_util = require("table_util")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")

local function create_test_ctx()
	local db_src = ServerSqliteDatabase(LjsqliteDatabase())
	db_src.path = ":memory:"
	db_src:open()

	-- db_src.orm:debug(true)

	local difftables_repo_src = DifftablesRepo(db_src.models)

	local user = User()
	user.id = 1
	user.user_roles = {UserRole("admin", 0)}

	local difftables_src = Difftables(difftables_repo_src)

	--

	local db_dst = ServerSqliteDatabase(LjsqliteDatabase())
	db_dst.path = ":memory:"
	db_dst:open()

	-- db_src.orm:debug(true)

	local difftables_repo_dst = DifftablesRepo(db_dst.models)
	local remote = DifftablesServerRemote(difftables_src)
	remote.user = user
	remote = DifftablesServerRemoteValidation(remote)

	local difftables_sync = DifftablesSync(remote, difftables_repo_dst)
	local difftables_dst = Difftables(difftables_repo_dst)

	---@param t testing.T
	local function assert_synced(t)
		t:tdeq(difftables_repo_dst:getDifftables(), difftables_repo_src:getDifftables())
		t:tdeq(difftables_repo_dst:getDifftableChartmetasAll(), difftables_repo_src:getDifftableChartmetasAll())
	end

	return {
		db_src = db_src,
		db_dst = db_dst,
		difftables_repo_src = difftables_repo_src,
		difftables_repo_dst = difftables_repo_dst,
		user = user,
		difftables_src = difftables_src,
		difftables_dst = difftables_dst,
		difftables_sync = difftables_sync,
		assert_synced = assert_synced,
	}
end

local test = {}

local function new_dt(name)
	local dt = Difftable()
	dt.name = name
	dt.description = ""
	dt.symbol = ""
	dt.tag = name
	return dt
end

---@param t testing.T
function test.difftable(t)
	local ctx = create_test_ctx()

	t:assert(ctx.difftables_src:create(ctx.user, new_dt("1")))
	t:tdeq({ctx.difftables_sync:sync()}, {1, 0})
	ctx.assert_synced(t)

	t:assert(ctx.difftables_src:create(ctx.user, new_dt("2")))
	t:tdeq({ctx.difftables_sync:sync()}, {1, 0})
	ctx.assert_synced(t)

	t:assert(ctx.difftables_src:create(ctx.user, new_dt("3")))
	t:assert(ctx.difftables_src:delete(ctx.user, 2))
	t:tdeq({ctx.difftables_sync:sync()}, {2, 0})
	ctx.assert_synced(t)

	-- TODO: difftable update
end

---@param t testing.T
function test.difftable_chartmetas(t)
	local ctx = create_test_ctx()

	ctx.difftables_sync.limit = 2

	ctx.difftables_src:create(ctx.user, new_dt("1"))
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "1", 1)
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "2", 1)
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "3", 1)
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "4", 1)
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "5", 1)

	t:tdeq({ctx.difftables_sync:sync()}, {1, 5})
	ctx.assert_synced(t)

	ctx.difftables_src:deleteDifftableChartmeta(ctx.user, 0, 1, "3", 1)
	ctx.difftables_src:setDifftableChartmeta(ctx.user, 0, 1, "6", 1)

	t:tdeq({ctx.difftables_sync:sync()}, {0, 2})
	ctx.assert_synced(t)
end

return test
