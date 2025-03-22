local IResource = require("web.framework.IResource")

---@class sea.UserSessionsResource: web.IResource
---@operator call: sea.UserSessionsResource
local UserSessionsResource = IResource + {}

UserSessionsResource.uri = "/users/:user_id/sessions"

---@param users sea.Users
---@param views web.Views
function UserSessionsResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserSessionsResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_sessions.etlua", ctx, true)
end

return UserSessionsResource
