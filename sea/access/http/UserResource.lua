local IResource = require("web.framework.IResource")

---@class sea.UserResource: web.IResource
---@operator call: sea.UserResource
local UserResource = IResource + {}

UserResource.uri = "/users/:user_id"

---@param users sea.Users
---@param views web.Views
function UserResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:GET(req, res, ctx)
	ctx.user = self.users:getUser(tonumber(ctx.path_params.user_id))
	self.views:render_send(res, "sea/access/http/user.etlua", ctx, true)
end

return UserResource
