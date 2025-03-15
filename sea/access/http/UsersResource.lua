local IResource = require("web.framework.IResource")
local UsersPage = require("sea.access.http.UsersPage")

---@class sea.UsersResource: web.IResource
---@operator call: sea.UsersResource
local UsersResource = IResource + {}

UsersResource.uri = "/users"

---@param users sea.Users
---@param views web.Views
function UsersResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UsersResource:GET(req, res, ctx)
	-- ctx.users = self.users:getUsers()
	ctx.users = {{name = "qwe"}}

	ctx.page = UsersPage(ctx.session_user, os.time())

	local vc = {["sea/shared/http/layout.etlua"] = "sea/access/http/users.etlua"}
	local s = self.views:render(vc, ctx)

	res.headers:set("Content-Type", "text/html")
	res:send(s)
end

return UsersResource
