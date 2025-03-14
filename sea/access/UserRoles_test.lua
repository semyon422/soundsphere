local UserRoles = require("sea.access.UserRoles")
local IPasswordHasher = require("sea.access.IPasswordHasher")
local UsersRepo = require("sea.access.repos.UsersRepo")
local Users = require("sea.access.Users")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

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

local test = {}

---@param t testing.T
function test.all(t)
	local ctx = create_test_ctx()

	local users = Users(ctx.users_repo, IPasswordHasher())

	local user_values = User()
	user_values.name = "user"
	user_values.email = "user@example.com"
	user_values.password = "password"

	local su = assert(users:register(ctx.anon_user, "127.0.0.1", 0, user_values))
	local _user_role = UserRole("owner", 0)
	_user_role.user_id = su.user.id
	su.user.user_roles = {_user_role}
	ctx.users_repo:createUserRole(_user_role)

	local user_roles = UserRoles(ctx.users_repo)

	---@type any, any, sea.UserRole
	local _, err, user_role

	_, err = user_roles:createRole(su.user, 0, 2, "owner")
	t:eq(err, "not_found")

	_, err = user_roles:createRole(su.user, 0, su.user.id, "owner")
	t:eq(err, "not_allowed")

	user_role, err = user_roles:createRole(su.user, 0, su.user.id, "moderator")
	t:assert(user_role, err)

	_, err = user_roles:createRole(su.user, 0, su.user.id, "moderator")
	t:eq(err, "found")

	user_role, err = user_roles:deleteRole(su.user, 0, su.user.id, "moderator")
	t:assert(user_role, err)

	_, err = user_roles:deleteRole(su.user, 0, su.user.id, "moderator")
	t:eq(err, "not_found")

	_, err = user_roles:deleteRole(su.user, 0, su.user.id, "owner")
	t:eq(err, "not_allowed")

	_, err = user_roles:deleteRole(su.user, 0, 2, "owner")
	t:eq(err, "not_found")

	--

	_, err = user_roles:addTimeRole(su.user, 0, su.user.id, "moderator", 10)
	t:eq(err, "not_found")

	user_role, err = user_roles:createRole(su.user, 0, su.user.id, "moderator")
	t:assert(user_role, err)

	user_role, err = user_roles:addTimeRole(su.user, 0, su.user.id, "moderator", 10)
	if t:assert(user_role, err) then
		---@cast user_role -?
		t:eq(user_role.expires_at, 10)
	end

	_, err = user_roles:addTimeRole(su.user, 0, su.user.id, "owner", 10)
	t:eq(err, "not_allowed")

	_, err = user_roles:addTimeRole(su.user, 0, 2, "owner", 10)
	t:eq(err, "not_found")

	--

	user_role, err = user_roles:makeUnexpirableRole(su.user, 0, su.user.id, "moderator")
	t:assert(user_role, err)

	_, err = user_roles:makeUnexpirableRole(su.user, 0, su.user.id, "owner")
	t:eq(err, "not_allowed")

	_, err = user_roles:makeUnexpirableRole(su.user, 0, su.user.id, "user")
	t:eq(err, "not_found")

	_, err = user_roles:makeUnexpirableRole(su.user, 0, 2, "user")
	t:eq(err, "not_found")
end

return test
