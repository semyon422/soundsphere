local CustomAccess = require("sea.access.CustomAccess")
local IPasswordHasher = require("sea.access.IPasswordHasher")
local UsersRepo = require("sea.access.repos.UsersRepo")
local Users = require("sea.access.Users")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase(LjsqliteDatabase())

	db.path = ":memory:"

	db:remove()
	db:open()

	-- db.orm:debug(true)

	local models = db.models
	local users_repo = UsersRepo(models)

	local anon_user = User()
	anon_user.id = 0

	return {
		db = db,
		users_repo = users_repo,
		anon_user = anon_user,
	}
end

---@param t testing.T
function test.owner_role_bypass(t)
	local access = {}
	function access:canUpdate(user, obj) return user.id == obj.owner_id end

	local time = 0
	local function clock() return time end

	local custom_access = CustomAccess(access, "qwe", clock)

	local user = User()
	user.id = 1

	local obj = {owner_id = 1}

	t:assert(access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))

	obj.owner_id = 2

	t:assert(not access:canUpdate(user, obj))
	t:assert(not custom_access:canUpdate(user, obj))

	local user_role = UserRole("owner", 0)
	table.insert(user.user_roles, user_role)

	t:assert(not access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))
end

---@param t testing.T
function test.has_role(t)
	local user = User()

	t:assert(not user:hasRole("owner", 0))

	local user_role = UserRole("admin", 0)
	table.insert(user.user_roles, user_role)

	t:assert(not user:hasRole("owner", 0))

	user_role = UserRole("owner", 0)
	table.insert(user.user_roles, user_role)

	t:assert(user:hasRole("owner", 0))
end

---@param t testing.T
function test.register_email_password(t)
	local ctx = create_test_ctx()

	local time = 0

	local users = Users(ctx.users_repo, IPasswordHasher())

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local su, err = users:register(ctx.anon_user, "127.0.0.1", time, user_values)

	if not t:assert(su, err) then
		return
	end
	---@cast su -?

	t:eq(su.session.id, 1)
	t:eq(su.session.user_id, 1)

	---@type any
	local _

	_, err = users:register(ctx.anon_user, "127.0.0.1", time, user_values)
	t:eq(err, "rate_exceeded")

	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:eq(err, "email_taken")

	user_values.email = "user2@example.com"
	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:eq(err, "name_taken")

	user_values.name = "user2"
	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:assert(su, err)

	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:eq(err, "rate_exceeded")

	time = time + users.ip_register_delay

	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:eq(err, "email_taken")

	users.is_register_enabled = false

	_, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	t:eq(err, "disabled")
end

---@param t testing.T
function test.login_email_password(t)
	local ctx = create_test_ctx()

	local time = 0

	local users = Users(ctx.users_repo, IPasswordHasher())

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local su, err = users:register(ctx.anon_user, "127.0.0.1", time, user_values)

	if not t:assert(su, err) then
		return
	end
	---@cast su -?

	t:eq(su.user.id, 1)

	local user_values = User()
	user_values.email = "user@example.com"
	user_values.password = "password"

	local su, err = users:login(ctx.anon_user, "127.0.0.1", time, user_values)

	if not t:assert(su, err) then
		return
	end
	---@cast su -?

	t:eq(su.session.user_id, su.user.id)

	---@type any
	local _

	user_values.email = "user2@example.com"
	_, err = users:login(ctx.anon_user, "127.0.0.1", time, user_values)
	t:eq(err, "invalid_credentials")

	user_values.email = "user@example.com"
	user_values.password = "password1"
	_, err = users:login(ctx.anon_user, "127.0.0.1", time, user_values)
	t:eq(err, "invalid_credentials")

	users.is_login_enabled = false

	user_values.password = "password"
	_, err = users:login(ctx.anon_user, "127.0.0.1", time, user_values)
	t:eq(err, "disabled")
end

---@param t testing.T
function test.login_email_link(t)
	-- TODO
end

---@param t testing.T
function test.login_quick(t)
	-- TODO
	-- same IP, limit by time
end

---@param t testing.T
function test.register_oauth_osu(t)
	-- TODO
end

---@param t testing.T
function test.login_oauth_osu(t)
	-- TODO
end

---@param t testing.T
function test.ban(t)
	local ctx = create_test_ctx()

	local time = 0

	local users = Users(ctx.users_repo, IPasswordHasher())

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local su, err = users:register(ctx.anon_user, "127.0.0.1", time, user_values)
	---@cast su -?

	local user_role = UserRole("owner", time)
	user_role:addTime(100, time)
	su.user.user_roles = {user_role}

	user_values.name = "user2"
	user_values.email = "user2@example.com"
	local su2, err = users:register(ctx.anon_user, "127.0.0.2", time, user_values)
	---@cast su2 -?

	local user, err = users:ban(su.user, time, su2.user.id)

	if not t:assert(user, err) then
		return
	end
	---@cast user -?

	t:eq(user.id, su2.user.id)
	t:assert(user.is_banned)

	local _, err = users:ban(su.user, 0, su.user.id)
	t:eq(err, "not_allowed")

	local _, err = users:ban(su.user, 0, 3)
	t:eq(err, "not_found")
end

return test
