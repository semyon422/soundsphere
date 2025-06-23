local Difftables = require("sea.difftables.Difftables")
local Difftable = require("sea.difftables.Difftable")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local difftables_repo = DifftablesRepo(models)
	local difftables = Difftables(difftables_repo)

	local user = User()
	user.id = 1
	user.user_roles = {UserRole("admin", 0)}

	return {
		db = db,
		difftables_repo = difftables_repo,
		difftables = difftables,
		user = user,
	}
end

---@param t testing.T
function test.basic(t)
	local ctx = create_test_ctx()

	local dt_values = Difftable()
	dt_values.name = "Difftable"
	dt_values.description = "test"
	dt_values.symbol = "*"
	dt_values.tag = ""

	local difftable, err = ctx.difftables:create(ctx.user, dt_values)
	if not t:assert(difftable, err) then
		return
	end

	---@cast difftable -?
	t:eq(difftable.name, "Difftable")

	local dt_cm, err = ctx.difftables:setDifftableChartmeta(ctx.user, 0, difftable.id, "", 1, 12)
	if not t:assert(dt_cm, err) then
		return
	end

	---@cast dt_cm -?
	t:eq(dt_cm.level, 12)
	t:eq(dt_cm.is_deleted, false)
	t:eq(dt_cm.created_at, 0)
	t:eq(dt_cm.updated_at, 0)

	local dt_cm, err = ctx.difftables:setDifftableChartmeta(ctx.user, 1, difftable.id, "", 1, 10)
	if not t:assert(dt_cm, err) then
		return
	end

	---@cast dt_cm -?
	t:eq(dt_cm.level, 10)
	t:eq(dt_cm.is_deleted, false)
	t:eq(dt_cm.created_at, 0)
	t:eq(dt_cm.updated_at, 1)

	local dt_cm, err = ctx.difftables:deleteDifftableChartmeta(ctx.user, 2, difftable.id, "", 1)
	if not t:assert(dt_cm, err) then
		return
	end

	---@cast dt_cm -?
	t:eq(dt_cm.level, 10)
	t:eq(dt_cm.is_deleted, true)
	t:eq(dt_cm.created_at, 0)
	t:eq(dt_cm.updated_at, 2)
end

return test
