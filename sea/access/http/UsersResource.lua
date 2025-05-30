local IResource = require("web.framework.IResource")
local UsersPage = require("sea.access.http.UsersPage")

---@class sea.UsersResource: web.IResource
---@operator call: sea.UsersResource
local UsersResource = IResource + {}

UsersResource.routes = {
	{"/users", {
		GET = "getUsers",
	}},
}

---@param users sea.Users
---@param views web.Views
function UsersResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UsersResource:getUsers(req, res, ctx)
	ctx.users = self.users:getUsers()
	ctx.page = UsersPage(ctx.session_user, os.time())
	self.views:render_send(res, "sea/access/http/users.etlua", ctx, true)
end

return UsersResource
