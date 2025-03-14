local class = require("class")
local UsersPage = require("sea.access.http.UsersPage")

---@class sea.UsersResource
---@operator call: sea.UsersResource
local UsersResource = class()

---@param users sea.Users
function UsersResource:new(users)
	self.users = users
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx table
function UsersResource:GET(req, res, ctx)
	ctx.users = self.users:getUsers()

	-- ctx.page = UsersPage(ctx.session_user, os.time())

	res:send("users")
	-- res:send(self.pages:render("Users", ctx))
end

return UsersResource
