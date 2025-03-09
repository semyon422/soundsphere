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

	local user, err = users:register(ctx.anon_user, user_values, "127.0.0.1")

	if not t:assert(user, err) then
		return
	end
	---@cast user -?

	t:eq(user.id, 1)

	user, err = users:register(ctx.anon_user, user_values, "127.0.0.1")
	t:eq(err, "rate_exceeded")

	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "email_taken")

	user_values.email = "user2@example.com"
	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "name_taken")

	user_values.name = "user2"
	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:assert(user, err)

	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "rate_exceeded")

	time = time + users.ip_register_delay

	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "email_taken")

	users.is_register_enabled = false

	user, err = users:register(ctx.anon_user, user_values, "127.0.0.2")
	t:eq(err, "disabled")
end

---@param t testing.T
function test.login_email_password(t)

	-- test attempts limit
end

---@param t testing.T
function test.login_email_link(t)

end

---@param t testing.T
function test.login_quick(t)

	-- same IP, limit by time
end

---@param t testing.T
function test.register_oauth_osu(t)

end

---@param t testing.T
function test.login_oauth_osu(t)

end

return test
