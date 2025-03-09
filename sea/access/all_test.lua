local CustomAccess = require("sea.access.CustomAccess")
local IPasswordHasher = require("sea.access.IPasswordHasher")
local UsersRepo = require("sea.access.repos.UsersRepo")
local Users = require("sea.access.Users")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")local table_util = require("table_util")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

local function create_test_ctx()
	local db = ServerSqliteDatabase()

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

	local custom_access = CustomAccess(access, "qwe")

	local user = User()
	user.id = 1

	local obj = {owner_id = 1}

	t:assert(access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))

	obj.owner_id = 2

	t:assert(not access:canUpdate(user, obj))
	t:assert(not custom_access:canUpdate(user, obj))

	local user_role = UserRole()
	user_role.role = "owner"
	table.insert(user.user_roles, user_role)

	t:assert(not access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))
end

---@param t testing.T
function test.has_role(t)
	local user = User()

	t:assert(not user:hasRole("owner"))

	local user_role = UserRole()
	user_role.role = "admin"
	table.insert(user.user_roles, user_role)

	t:assert(not user:hasRole("owner"))

	user_role = UserRole()
	user_role.role = "owner"
	table.insert(user.user_roles, user_role)

	t:assert(user:hasRole("owner"))
end

---@param t testing.T
function test.register_email_password(t)
	local ctx = create_test_ctx()

	local time = 0

	local users = Users(ctx.users_repo, IPasswordHasher(), function() return time end)

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local session, err = users:register(ctx.anon_user, user_values, "127.0.0.1")

	if not t:assert(session, err) then
		return
	end
	---@cast session -?

	t:eq(session.id, 1)
	t:eq(session.user_id, 1)

	session, err = users:register(ctx.anon_user, user_values, "127.0.0.1")
	t:eq(err, "rate_exceeded")

	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "email_taken")

	user_values.email = "user2@example.com"
	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "name_taken")

	user_values.name = "user2"
	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:assert(session, err)

	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "rate_exceeded")

	time = time + users.ip_register_delay

	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "email_taken")

	users.is_register_enabled = false

	session, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "disabled")
end

---@param t testing.T
function test.login_email_password(t)
	local ctx = create_test_ctx()

	local time = 0

	local users = Users(ctx.users_repo, IPasswordHasher(), function() return time end)

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local user, err = users:register(ctx.anon_user, user_values, "127.0.0.1")

	if not t:assert(user, err) then
		return
	end
	---@cast user -?

	t:eq(user.id, 1)

	local session, err = users:login(ctx.anon_user, "127.0.0.1", "user@example.com", "password")

	if not t:assert(session, err) then
		return
	end
	---@cast session -?

	t:eq(session.user_id, user.id)

	session, err = users:login(ctx.anon_user, "127.0.0.1", "user2@example.com", "password")
	t:eq(err, "invalid_credentials")

	session, err = users:login(ctx.anon_user, "127.0.0.1", "user@example.com", "password1")
	t:eq(err, "invalid_credentials")

	users.is_login_enabled = false

	session, err = users:login(ctx.anon_user, "127.0.0.1", "user@example.com", "password")
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

return test
